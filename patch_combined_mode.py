import json

PATH = r'c:\Users\calli\OneDrive\Programmazione\github\FromZeroToQuant-\14_stocks_analysis\05_stocks_ranking.ipynb'

with open(PATH, 'r', encoding='utf-8') as f:
    nb = json.load(f)

cells = nb['cells']

def find_cell(substr):
    for i, c in enumerate(cells):
        if substr in ''.join(c.get('source', [])):
            return i
    raise ValueError(f'Cell not found: {substr!r}')

def get_src(i):
    return ''.join(cells[i]['source'])

def set_src(i, src):
    cells[i]['source'] = src

def patch(i, old, new):
    src = get_src(i)
    if old not in src:
        raise AssertionError(f'Pattern not found in cell {i}:\n{old!r}\n\nActual src:\n{src!r}')
    set_src(i, src.replace(old, new, 1))

# ── 1. Cell 2: validation/print updated for combined mode ─────────────────────
i = find_cell("if not use_stocks_list:\n    missing_dirs")
patch(i,
    "if not use_stocks_list:\n"
    "    missing_dirs = [path for path in selected_dirs if not os.path.isdir(path)]\n"
    "    if missing_dirs:\n"
    "        raise FileNotFoundError(f'Directories do not exist: {missing_dirs}')\n"
    "\n"
    "if use_stocks_list:\n"
    "    print('Using stocks list:', stocks)\n"
    "else:\n"
    "    print('Using data directories:')\n"
    "    for path in selected_dirs:\n"
    "        print(f' - {path}')",
    "if selected_dirs:\n"
    "    missing_dirs = [path for path in selected_dirs if not os.path.isdir(path)]\n"
    "    if missing_dirs:\n"
    "        raise FileNotFoundError(f'Directories do not exist: {missing_dirs}')\n"
    "\n"
    "if use_stocks_list and selected_dirs:\n"
    "    print('Combined mode: rankings + stocks list')\n"
    "    for path in selected_dirs:\n"
    "        print(f' - {path}')\n"
    "    print('Stocks list:', stocks)\n"
    "elif use_stocks_list:\n"
    "    print('Using stocks list:', stocks)\n"
    "else:\n"
    "    print('Using data directories:')\n"
    "    for path in selected_dirs:\n"
    "        print(f' - {path}')"
)
print(f'Cell 2 (idx {i}): validation/print updated')

# ── 2. Cell 3: flip if/else so selected_dirs is primary branch ────────────────
# In combined mode selected_dirs is True → rankings load; manual stocks appended later.
# In pure stocks-list mode selected_dirs is empty → else branch.
i = find_cell("build df directly from the manually entered stocks list")
set_src(i,
    "if selected_dirs:\n"
    "    # rankings mode (or combined): load from files\n"
    "    # in combined mode, manual stocks are appended after ranking-specific processing\n"
    "    files = []\n"
    "\n"
    "    for dir_path in selected_dirs:\n"
    "        dir_files = [\n"
    "            file for file in os.listdir(dir_path)\n"
    "            if file.lower().endswith(('.csv', '.xlsx', '.xls'))\n"
    "        ]\n"
    "        files.extend([(dir_path, file) for file in dir_files])\n"
    "\n"
    "    if not files:\n"
    "        raise ValueError(f'No CSV/XLSX/XLS files found in selected directories: {selected_dirs}')\n"
    "\n"
    "    def load_table(dir_path, file_name):\n"
    "        file_path = os.path.join(dir_path, file_name)\n"
    "        if file_name.lower().endswith('.csv'):\n"
    "            return pd.read_csv(file_path)\n"
    "        return pd.read_excel(file_path)\n"
    "\n"
    "    # file name format like 2603, 2602... first two digits year, last two month\n"
    "    def extract_date(file_name):\n"
    "        year = int(file_name[:2]) + 2000\n"
    "        month = int(file_name[2:4])\n"
    "        return pd.Timestamp(year=year, month=month, day=1)\n"
    "\n"
    "    df = pd.concat(\n"
    "        [\n"
    "            load_table(dir_path, file_name).assign(\n"
    "                date=extract_date(file_name),\n"
    "                source_dir=os.path.basename(dir_path),\n"
    "            )\n"
    "            for dir_path, file_name in sorted(files, key=lambda x: (x[0], x[1]))\n"
    "        ],\n"
    "        ignore_index=True,\n"
    "    )\n"
    "\n"
    "    # lowercase column names\n"
    "    df.columns = df.columns.str.lower()\n"
    "\n"
    "    # replace spaces with underscore in column names\n"
    "    df.columns = df.columns.str.replace(' ', '_')\n"
    "\n"
    "    df.head()\n"
    "\n"
    "else:\n"
    "    # pure stocks list mode: build df directly from the manually entered stocks list\n"
    "    df = pd.DataFrame({'symbol': stocks})\n"
    "    df.head()\n"
)
print(f'Cell 3 (idx {i}): build df updated')

# ── 3. Guard cells: `if not use_stocks_list:` → `if selected_dirs:` ──────────
# These cells do rankings-specific processing that must also run in combined mode.
guard_markers = [
    "create a copy of symbol column named 'symbol_copy'",
    "should be shifted backwards by 1 row",
    "drop nan in df.unnamed:_0",
    "rename column 'symbol_copy' to 'symbol'",
    "group by symbol and count the number of occurrences",
    "drop duplicates in df.symbol, keep last occurrence",
    "market cap column is object. We need to convert it",
    "if market cap um is M, market cap / 1000",
    "rename market cap converted to market cap",
    "drop all rows where market cap um is M and K",
    "--- solidity filter ---",
    "--- fair_value_(%) filter ---",
]
for marker in guard_markers:
    idx = find_cell(marker)
    patch(idx, "if not use_stocks_list:\n", "if selected_dirs:\n")
    print(f'  Guard cell {idx}: OK  ({marker[:50]})')

# ── 4. New cell: append manual stocks in combined mode ────────────────────────
# Inserted right before the "tickers = df['symbol'].tolist()" cell.
i_tickers = find_cell("list of tickers in the dataframe")
new_cell = {
    "cell_type": "code",
    "execution_count": None,
    "id": "comb_append_01",
    "metadata": {},
    "outputs": [],
    "source": (
        "# combined mode: append manually entered stocks to the rankings-filtered df\n"
        "# (ranking-specific filters above already ran; manual stocks bypass them intentionally)\n"
        "if use_stocks_list and selected_dirs:\n"
        "    existing = set(df['symbol'].values)\n"
        "    extra = pd.DataFrame({'symbol': [s for s in stocks if s not in existing]})\n"
        "    df = pd.concat([df, extra], ignore_index=True)\n"
        "    print(f'Combined mode: {len(df)} total rows ({len(extra)} manual stock(s) appended)')\n"
    )
}
cells.insert(i_tickers, new_cell)
print(f'New cell inserted at idx {i_tickers} (combined mode append)')

with open(PATH, 'w', encoding='utf-8') as f:
    json.dump(nb, f, indent=1, ensure_ascii=False)

print('\nAll done.')
