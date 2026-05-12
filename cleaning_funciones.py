import pandas as pd


# Load dataset
def load_data(path):
    
    df = pd.read_csv(path)
    
    return df


# Merge both web datasets
def merge_web_data(df1, df2):
    
    merged_df = pd.concat([df1, df2], ignore_index=True)
    
    return merged_df


# Clean column names
def clean_columns(df):
    
    df.columns = df.columns.str.strip().str.lower()
    
    return df


# Remove duplicated rows
def remove_duplicates(df):
    
    df = df.drop_duplicates()
    
    return df


# Check missing values
def check_nulls(df):
    
    nulls = pd.DataFrame({
        'null_count': df.isnull().sum(),
        'null_percentage': round(df.isnull().mean()*100, 2)
    })
    
    return nulls


# Convert date column into datetime format
def datetime_conversion(df, column):
    
    df[column] = pd.to_datetime(df[column])
    
    return df


# Sort user process step
def sort_data(df):
    
    df = df.sort_values(
        by=['client_id', 'visit_id', 'date_time']
    )
    
    return df


# Reset index
def reset_dataframe_index(df):
    
    df = df.reset_index(drop=True)
    
    return df


# Export cleaned dataset
def export_clean_csv(df, output_name):
    
    df.to_csv(output_name, index=False)