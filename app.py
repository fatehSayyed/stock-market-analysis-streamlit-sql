"""Stock Market Analysis Dashboard + SQL Playground  (run: python -m streamlit run app.py)."""
from datetime import date

import streamlit as st

st.set_page_config(page_title="Stock Market Analysis", page_icon="📈", layout="wide",
                   initial_sidebar_state="expanded")

from utils import state, ui  # noqa: E402  (after set_page_config)
from views import (comparison, dataset_mgmt, eda, insights, market_overview,  # noqa: E402
                   sql_playground, stock_explorer)

PAGES = {
    "Market Overview": market_overview,
    "Stock Explorer": stock_explorer,
    "Exploratory Data Analysis": eda,
    "Company Comparison": comparison,
    "SQL Playground": sql_playground,
    "Insights & Reports": insights,
    "Dataset Management": dataset_mgmt,
}


def main():
    ui.inject_css()
    state.init_state()

    with st.sidebar:
        st.markdown('<div class="brand">📈 STOCK<span>LENS</span></div>', unsafe_allow_html=True)
        page = st.radio("Navigation", list(PAGES), label_visibility="collapsed", key="nav")
        df = state.get_df()
        if state.has_data():
            last = df["Date"].max().date()
            st.markdown(f'<div class="side-note"><b>Historical data</b><br>Last record: {last:%d %b %Y}<br>'
                        f'Today: {date.today():%d %b %Y}<br>{len(df):,} rows · {df["Company"].nunique()} companies<br><br>'
                        'For analysis and learning only – not live prices, not investment advice.</div>',
                        unsafe_allow_html=True)

    if not state.has_data():
        st.title("No data loaded")
        st.warning(st.session_state.get("load_error", "No dataset is available."))
        st.info("Place the six company CSV files in the `data/` folder and reload, or upload them below.")
        dataset_mgmt.render(df)
        return

    try:
        PAGES[page].render(df)
    except Exception as exc:                                    # keep the app alive on unexpected errors
        st.error(f"Something went wrong on this page: {exc}")
        st.exception(exc)


main()
