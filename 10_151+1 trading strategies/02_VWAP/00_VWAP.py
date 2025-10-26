import pandas as pd
import numpy as np
from flask import Flask, request, jsonify
from io import StringIO

# Initialize Flask app
app = Flask(__name__)

# VWAP calculation function
def calculate_vwap(df):
    print("Calculating VWAP...")  # Log to CMD

    # Ensure critical columns have no missing values
    df = df.dropna(subset=['volume', 'high', 'low', 'open', 'close'])

    # Convert 'date' column to datetime
    df.loc[:, 'date'] = pd.to_datetime(df['date'])

    # Handle zero volume by replacing with NaN and dropping invalid rows
    df.loc[:, 'volume'] = df['volume'].replace(0, np.nan)
    df = df.dropna(subset=['volume'])

    # Check if data exists after filtering
    if df.empty:
        print("No data to calculate VWAP.")
        return pd.DataFrame()

    # Calculate VWAP and additional metrics
    df.loc[:, 'typical_price'] = (df['high'] + df['low'] + df['close']) / 3
    df.loc[:, 'vwap'] = (df['typical_price'] * df['volume']).cumsum() / df['volume'].cumsum()
    df.loc[:, 'avg_price'] = df[['high', 'low', 'open', 'close']].mean(axis=1)
    df.loc[:, 'avg_volume'] = df['volume'].rolling(window=2, min_periods=1).mean()
    df.loc[:, 'major_support'] = df['low'].min()
    df.loc[:, 'major_resistance'] = df['high'].max()
    df.loc[:, 'minor_support'] = df['low'].rolling(window=3, min_periods=1).mean()
    df.loc[:, 'minor_resistance'] = df['high'].rolling(window=3, min_periods=1).mean()

    # Calculate strength and generate signals
    df.loc[:, 'strength'] = np.where(
        (df['high'] - df['low']) != 0,
        np.abs(df['close'] - df['open']) / (df['high'] - df['low']) * 100,
        0
    )
    df.loc[:, 'signal'] = np.where(
        df['close'] > df['vwap'], 'BUY',
        np.where(df['close'] < df['vwap'], 'SELL', 'NEUTRAL')
    )
    df.loc[:, 'signal_explanation'] = np.where(
        df['signal'] == 'BUY',
        'The price is trading above the VWAP, indicating bullish market tendencies.',
        np.where(
            df['signal'] == 'SELL',
            'The price is trading below the VWAP, indicating bearish market tendencies.',
            'The price is trading at the VWAP, indicating equilibrium in the market.'
        )
    )

    # Entry suggestion (removed SL and TP)
    df.loc[:, 'entry_point'] = np.where(
        df['signal'] == 'BUY', df['vwap'],
        np.where(df['signal'] == 'SELL', df['vwap'], np.nan)
    )

    # Return data with major and minor support/resistance levels included
    return df[['date', 'vwap', 'signal', 'signal_explanation', 'entry_point', 'major_support', 'major_resistance', 'minor_support', 'minor_resistance']].iloc[-1]

# Route to handle incoming data
@app.route('/vwap', methods=['POST'])
def vwap():
    try:
        # Receive CSV data from EA
        data = request.data.decode('utf-8')
        print(f"Received data: {data[:200]}...")  # Log first 200 chars to ensure data is received correctly

        # Load data into DataFrame
        df = pd.read_csv(StringIO(data))

        # Calculate VWAP and generate signals
        result = calculate_vwap(df)

        # Send response back to EA with signal, signal explanation, entry point, and support/resistance levels
        response = {
            'vwap': result['vwap'],
            'signal': result['signal'],
            'signal_explanation': result['signal_explanation'],
            'entry_point': result['entry_point'],
            'major_support': result['major_support'],
            'major_resistance': result['major_resistance'],
            'minor_support': result['minor_support'],
            'minor_resistance': result['minor_resistance']
        }
        return jsonify(response)

    except Exception as e:
        print(f"Error processing request: {e}")
        return jsonify({'error': 'Error processing the data'}), 500

if __name__ == '__main__':
    app.run(host='127.0.0.1', port=5080, debug=True)
