#!/usr/bin/env python3
import pandas as pd
import sys
import os

def split_excel_sheets(input_file):
    try:
        # Read the Excel file
        xlsx = pd.ExcelFile(input_file)
        
        # Get all sheet names
        sheet_names = xlsx.sheet_names
        
        input_basename = os.path.splitext(os.path.basename(input_file))[0]
        
        # For each sheet, create a new Excel file
        for sheet in sheet_names:
            # Read the sheet
            df = pd.read_excel(input_file, sheet_name=sheet)
            
            # Create new Excel file with the sheet name
            output_file = f'{input_basename}_{sheet}.xlsx'
            df.to_excel(output_file, index=False)
            print(f'Created: {output_file}')
            
    except FileNotFoundError:
        print(f"Error: File '{input_file}' not found")
    except Exception as e:
        print(f"Error: {str(e)}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python sheet2xls.py <input_excel_file>")
        sys.exit(1)
    
    input_file = sys.argv[1]
    split_excel_sheets(input_file)
