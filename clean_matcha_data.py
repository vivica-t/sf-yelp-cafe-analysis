import pandas as pd
import ast

# read raw data
df = pd.read_csv('raw_matcha_data.csv')

# keeping columns we will use
cols = df[[
    'name',
    'review_count',
    'categories',
    'rating',
    'transactions',
    'price',
    'location.address1',
    'location.city',
    'location.state',
    'location.zip_code'
]].copy()

# renaming columns
cols.columns = [
    'name',
    'review_count',
    'categories',
    'rating',
    'transactions',
    'price',
    'address',
    'city',
    'state',
    'zip_code'
]

def clean_transactions(txns):
    cleaned = []
    for val in txns:
        try:
            if isinstance(val, str):
                txn_list = ast.literal_eval(val)
            elif isinstance(val, list): 
                txn_list = val
            if isinstance(txn_list, list):
                cleaned.append(", ".join(txn_list))
            else:
                cleaned.append(None)
        except Exception:
            cleaned.append(None)
    return cleaned


def clean_categories(cats):
    cleaned = []
    for val in cats:
        try:
            if isinstance(val, str):
                category_list = ast.literal_eval(val)
            elif isinstance(val, list): 
                category_list = val
            aliases = []
            for x in category_list:
                if isinstance(x, dict) and "alias" in x:
                    aliases.append(x["alias"])
            cleaned.append(", ".join(aliases))
        except Exception:
            cleaned.append(None)
    return cleaned



# these columns are being edited/overwrittten
cols.loc[:, 'transactions'] = clean_transactions(cols['transactions'])
cols.loc[:, 'categories'] = clean_categories(cols['categories'])

# filling in blanks
cols.loc[:, 'price'] = cols['price'].replace('', None).fillna('unknown')
cols.loc[:, 'transactions'] = cols['transactions'].replace('', None).fillna("none")
cols.loc[:, 'categories'] = cols['categories'].replace('', None).fillna("none")



# creating price_tier and price_tier_num columns to bypass matplotlib latex issues
price_signs = cols['price'].fillna('').astype(str).str.replace(r'[^$]', '', regex=True)
tier_len = price_signs.str.len().clip(lower=0, upper=4)
label_map = {0: 'unknown', 1: 'budget', 2: 'moderate', 3: 'expensive', 4: 'luxury'}
cols.loc[:, 'price_tier'] = tier_len.map(label_map)
cols.loc[:, 'price_tier_num'] = tier_len  

# removing any non SF rows
cols = cols[
    cols['city'].astype(str).str.strip().str.casefold() == "san francisco"
].copy()

# checking for blank values
# print(df_clean.isna().sum())

# saving cleaned dataset
cols.to_csv('clean_matcha_data2.csv', index=False)
# print("Cleaned data saved to clean_matcha_data.csv")
