import json

path = r'c:\Users\calli\OneDrive\Programmazione\github\FromZeroToQuant-\14_stocks_analysis\05_stocks_ranking.ipynb'

with open(path, 'r', encoding='utf-8') as f:
    nb = json.load(f)

new_source = [
    '# --- market cap filter (stocks list only) ---\n',
    '# fv_market_cap comes from finviz as a string like "1.50B", "337.71M", etc.\n',
    '# Convert to billions for comparison; skip if using rankings (already filtered there).\n',
    'if use_stocks_list and \'fv_market_cap\' in df.columns:\n',
    '    def _parse_mc_to_billions(val):\n',
    '        if pd.isna(val):\n',
    '            return None\n',
    "        s = str(val).strip().upper().replace(',', '')\n",
    "        if s.endswith('T'):\n",
    "            return float(s[:-1]) * 1000\n",
    "        elif s.endswith('B'):\n",
    "            return float(s[:-1])\n",
    "        elif s.endswith('M'):\n",
    "            return float(s[:-1]) / 1000\n",
    "        elif s.endswith('K'):\n",
    "            return float(s[:-1]) / 1_000_000\n",
    '        try:\n',
    '            return float(s)\n',
    '        except ValueError:\n',
    '            return None\n',
    '\n',
    "    fv_mc_b = df['fv_market_cap'].apply(_parse_mc_to_billions)\n",
    '    df = df[~(fv_mc_b.notna() & (fv_mc_b < 10))]\n',
]

nb['cells'][43]['source'] = new_source

with open(path, 'w', encoding='utf-8') as f:
    json.dump(nb, f, indent=1, ensure_ascii=False)

print('done')

