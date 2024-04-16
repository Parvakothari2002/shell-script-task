#!/bin/bash

# Function to display usage instructions
usage() {
    echo "Usage: $0 [-s start_date] [-e end_date] [-c category]"
    echo "Options:"
    echo "  -s start_date: Start date for filtering data (YYYY-MM-DD)"
    echo "  -e end_date: End date for filtering data (YYYY-MM-DD)"
    echo "  -c category: Category to filter data"
    exit 1
}

# Parse command line arguments
while getopts ":s:e:c:" opt; do
    case ${opt} in
        s)
            start_date=$OPTARG
            ;;
        e)
            end_date=$OPTARG
            ;;
        c)
            category=$OPTARG
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND -1))

# Validate input arguments
if [ -n "$start_date" ] && [ -z "$end_date" ]; then
    echo "Error: End date is required when providing start date."
    usage
fi

# Filter data if start and end dates are provided
if [ -n "$start_date" ] && [ -n "$end_date" ]; then
    awk -F ',' -v start="$start_date" -v end="$end_date" '$1 >= start && $1 <= end' sales_data.csv > filtered_sales_data.csv
    sales_file="filtered_sales_data.csv"
else
    sales_file="sales_data.csv"
fi

# Filter data by category if provided
if [ -n "$category" ]; then
    grep "$category" "$sales_file" > temp_sales_data.csv
    sales_file="temp_sales_data.csv"
fi

# Calculate total sales
total_sales=$(awk -F ',' '{ total += $4 } END { print total }' "$sales_file")

# Calculate average sales per month
average_sales=$(awk -F ',' '{ total += $4; count++ } END { print total/count }' "$sales_file")

# Find best-selling products
best_selling_products=$(awk -F ',' '{ print $2 }' "$sales_file" | sort | uniq -c | sort -rn | head -n 3)

# Generate summary report
echo "Summary Report:"
echo "Total Sales: $total_sales"
echo "Average Sales per Month: $average_sales"
echo "Best Selling Products:"
echo "$best_selling_products"

# Clean up temporary files
rm -f temp_sales_data.csv filtered_sales_data.csv
