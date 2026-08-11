from pathlib import Path
from datetime import timedelta
import json
import random

import numpy as np
import pandas as pd
from faker import Faker


# ============================================================
# CONFIGURATION
# ============================================================

SEED = 42
START_DATE = "2025-01-01"
END_DATE = "2025-12-31"
JSON_CHUNK_SIZE = 10_000

BASE_DIR = Path(__file__).resolve().parent
RAW_DIR = BASE_DIR / "raw"

random.seed(SEED)
np.random.seed(SEED)
fake = Faker()
Faker.seed(SEED)


# ============================================================
# HELPERS
# ============================================================

def create_directories() -> None:
    """Create folders for each simulated source system."""

    sources = [
        "google_ads",
        "meta_ads",
        "ga4",
        "hubspot",
        "stripe",
        "learnloop",
    ]

    for source in sources:
        (RAW_DIR / source).mkdir(parents=True, exist_ok=True)


def clear_generated_json_files() -> None:
    """Remove old generated JSON files before creating new ones."""

    if not RAW_DIR.exists():
        return

    for source_dir in RAW_DIR.iterdir():
        if source_dir.is_dir():
            for json_file in source_dir.glob("*.json"):
                json_file.unlink()


def save_json_records(
    dataframe: pd.DataFrame,
    output_dir: Path,
    file_prefix: str,
    chunk_size: int = JSON_CHUNK_SIZE,
) -> list[Path]:
    """Save a dataframe as paginated API-style JSON files."""

    if chunk_size <= 0:
        raise ValueError("chunk_size must be greater than zero.")

    output_dir.mkdir(parents=True, exist_ok=True)

    records = dataframe.to_dict(orient="records")
    total_records = len(records)
    total_pages = max(
        1,
        (total_records + chunk_size - 1) // chunk_size,
    )
    generated_at = pd.Timestamp.now().isoformat()
    created_files = []

    for page_number in range(1, total_pages + 1):
        start_index = (page_number - 1) * chunk_size
        end_index = min(
            start_index + chunk_size,
            total_records,
        )
        page_records = records[start_index:end_index]

        api_response = {
            "data": page_records,
            "record_count": len(page_records),
            "total_record_count": total_records,
            "page_number": page_number,
            "total_pages": total_pages,
            "has_more": page_number < total_pages,
            "generated_at": generated_at,
        }

        filepath = output_dir / (
            f"{file_prefix}_part_{page_number:04d}.json"
        )

        with filepath.open("w", encoding="utf-8") as file:
            json.dump(
                api_response,
                file,
                indent=2,
                default=str,
            )

        created_files.append(filepath)

    return created_files


def weighted_choice(options: list, probabilities: list):
    """Return one value using custom probabilities."""

    return np.random.choice(options, p=probabilities)


# ============================================================
# REFERENCE DATA
# ============================================================

CHANNELS = {
    "google_ads": {
        "channel_name": "Google Ads",
        "campaign_prefix": "GADS",
    },
    "meta_ads": {
        "channel_name": "Meta Ads",
        "campaign_prefix": "META",
    },
}

DEVICES = ["desktop", "mobile", "tablet"]
DEVICE_PROBABILITIES = [0.48, 0.45, 0.07]

COUNTRIES = [
    "United States",
    "Canada",
    "United Kingdom",
    "Australia",
    "Colombia",
]

COUNTRY_PROBABILITIES = [0.45, 0.15, 0.15, 0.10, 0.15]

LANDING_PAGES = [
    "/courses/data-analytics",
    "/courses/python",
    "/courses/sql",
    "/corporate-training",
    "/pricing",
    "/free-trial",
]

PLANS = [
    {
        "plan_id": "PLAN_STARTER",
        "plan_name": "Starter",
        "monthly_price": 29.00,
        "probability": 0.60,
    },
    {
        "plan_id": "PLAN_PRO",
        "plan_name": "Professional",
        "monthly_price": 79.00,
        "probability": 0.32,
    },
    {
        "plan_id": "PLAN_ENTERPRISE",
        "plan_name": "Enterprise",
        "monthly_price": 299.00,
        "probability": 0.08,
    },
]

COURSES = [
    {
        "course_id": "COURSE_001",
        "course_name": "Python Fundamentals",
        "category": "Programming",
    },
    {
        "course_id": "COURSE_002",
        "course_name": "SQL for Data Analysis",
        "category": "Data Analytics",
    },
    {
        "course_id": "COURSE_003",
        "course_name": "Tableau Dashboard Design",
        "category": "Business Intelligence",
    },
    {
        "course_id": "COURSE_004",
        "course_name": "Digital Marketing Analytics",
        "category": "Marketing",
    },
    {
        "course_id": "COURSE_005",
        "course_name": "Data Engineering Foundations",
        "category": "Data Engineering",
    },
    {
        "course_id": "COURSE_006",
        "course_name": "Machine Learning Essentials",
        "category": "Data Science",
    },
]


# ============================================================
# CAMPAIGNS
# ============================================================

def generate_campaigns() -> pd.DataFrame:
    """Generate campaign master data."""

    campaigns = [
        {
            "campaign_id": "GADS_001",
            "campaign_name": "Google Brand Search",
            "source_system": "google_ads",
            "campaign_type": "Brand Search",
            "base_ctr": 0.085,
            "base_cpc": 1.15,
            "session_rate": 0.94,
            "lead_rate": 0.13,
        },
        {
            "campaign_id": "GADS_002",
            "campaign_name": "Google Data Analytics Courses",
            "source_system": "google_ads",
            "campaign_type": "Non-Brand Search",
            "base_ctr": 0.055,
            "base_cpc": 1.85,
            "session_rate": 0.91,
            "lead_rate": 0.09,
        },
        {
            "campaign_id": "GADS_003",
            "campaign_name": "Google Corporate Training",
            "source_system": "google_ads",
            "campaign_type": "B2B Search",
            "base_ctr": 0.042,
            "base_cpc": 3.40,
            "session_rate": 0.90,
            "lead_rate": 0.11,
        },
        {
            "campaign_id": "GADS_004",
            "campaign_name": "Google Display Remarketing",
            "source_system": "google_ads",
            "campaign_type": "Remarketing",
            "base_ctr": 0.025,
            "base_cpc": 0.75,
            "session_rate": 0.88,
            "lead_rate": 0.07,
        },
        {
            "campaign_id": "META_001",
            "campaign_name": "Meta Data Career Awareness",
            "source_system": "meta_ads",
            "campaign_type": "Awareness",
            "base_ctr": 0.022,
            "base_cpc": 0.65,
            "session_rate": 0.85,
            "lead_rate": 0.045,
        },
        {
            "campaign_id": "META_002",
            "campaign_name": "Meta Free Trial",
            "source_system": "meta_ads",
            "campaign_type": "Conversion",
            "base_ctr": 0.038,
            "base_cpc": 1.10,
            "session_rate": 0.87,
            "lead_rate": 0.085,
        },
        {
            "campaign_id": "META_003",
            "campaign_name": "Meta Course Remarketing",
            "source_system": "meta_ads",
            "campaign_type": "Remarketing",
            "base_ctr": 0.048,
            "base_cpc": 0.95,
            "session_rate": 0.90,
            "lead_rate": 0.11,
        },
        {
            "campaign_id": "META_004",
            "campaign_name": "Meta Corporate Learning",
            "source_system": "meta_ads",
            "campaign_type": "B2B Lead Generation",
            "base_ctr": 0.028,
            "base_cpc": 2.20,
            "session_rate": 0.86,
            "lead_rate": 0.095,
        },
    ]

    campaign_df = pd.DataFrame(campaigns)

    campaign_df["start_date"] = START_DATE
    campaign_df["end_date"] = END_DATE
    campaign_df["status"] = "ACTIVE"

    return campaign_df


# ============================================================
# MARKETING PERFORMANCE
# ============================================================

def get_seasonality_multiplier(date: pd.Timestamp) -> float:
    """Apply monthly and weekly business patterns."""

    month_multiplier = {
        1: 1.20,
        2: 1.05,
        3: 1.00,
        4: 0.95,
        5: 0.90,
        6: 0.85,
        7: 0.90,
        8: 1.15,
        9: 1.10,
        10: 1.05,
        11: 1.30,
        12: 1.25,
    }

    multiplier = month_multiplier[date.month]

    # B2B and education traffic is normally lower on weekends.
    if date.dayofweek >= 5:
        multiplier *= 0.72

    return multiplier


def generate_marketing_performance(
    campaigns: pd.DataFrame,
) -> pd.DataFrame:
    """Generate daily Google Ads and Meta Ads performance."""

    dates = pd.date_range(START_DATE, END_DATE, freq="D")
    records = []

    for date in dates:
        seasonality = get_seasonality_multiplier(date)

        for campaign in campaigns.to_dict(orient="records"):
            base_impressions = {
                "Brand Search": 4500,
                "Non-Brand Search": 8500,
                "B2B Search": 2800,
                "Remarketing": 6500,
                "Awareness": 16000,
                "Conversion": 11000,
                "B2B Lead Generation": 5500,
            }.get(campaign["campaign_type"], 6000)

            impressions = int(
                base_impressions
                * seasonality
                * np.random.uniform(0.80, 1.20)
            )

            ctr = max(
                0.005,
                np.random.normal(
                    campaign["base_ctr"],
                    campaign["base_ctr"] * 0.12,
                ),
            )

            clicks = int(impressions * ctr)

            cpc = max(
                0.20,
                np.random.normal(
                    campaign["base_cpc"],
                    campaign["base_cpc"] * 0.10,
                ),
            )

            cost = round(clicks * cpc, 2)

            records.append(
                {
                    "date": date.date().isoformat(),
                    "campaign_id": campaign["campaign_id"],
                    "campaign_name": campaign["campaign_name"],
                    "source_system": campaign["source_system"],
                    "campaign_type": campaign["campaign_type"],
                    "impressions": impressions,
                    "clicks": clicks,
                    "ctr": round(clicks / impressions, 4)
                    if impressions
                    else 0,
                    "average_cpc": round(cpc, 2),
                    "cost": cost,
                }
            )

    return pd.DataFrame(records)


# ============================================================
# GA4 SESSIONS
# ============================================================

def generate_sessions(
    marketing_df: pd.DataFrame,
    campaigns: pd.DataFrame,
) -> pd.DataFrame:
    """Generate GA4 sessions from advertising clicks."""

    campaign_lookup = campaigns.set_index("campaign_id").to_dict(
        orient="index"
    )

    session_records = []
    session_counter = 1
    user_counter = 1

    for marketing_row in marketing_df.to_dict(orient="records"):
        campaign = campaign_lookup[marketing_row["campaign_id"]]

        session_count = int(
            marketing_row["clicks"]
            * campaign["session_rate"]
            * np.random.uniform(0.96, 1.03)
        )

        for _ in range(session_count):
            device = weighted_choice(
                DEVICES,
                DEVICE_PROBABILITIES,
            )

            country = weighted_choice(
                COUNTRIES,
                COUNTRY_PROBABILITIES,
            )

            landing_page = random.choice(LANDING_PAGES)

            # Most visitors are new, but some are returning users.
            is_returning = np.random.random() < 0.20

            if is_returning and user_counter > 100:
                user_id = f"USR_{random.randint(1, user_counter - 1):07d}"
            else:
                user_id = f"USR_{user_counter:07d}"
                user_counter += 1

            device_conversion_multiplier = {
                "desktop": 1.25,
                "mobile": 0.80,
                "tablet": 0.90,
            }[device]

            base_engagement_probability = 0.66
            engagement_probability = min(
                base_engagement_probability
                * device_conversion_multiplier,
                0.90,
            )

            engaged = np.random.random() < engagement_probability
            bounced = not engaged

            if engaged:
                page_views = max(2, int(np.random.normal(5, 2)))
                duration_seconds = max(
                    45,
                    int(np.random.normal(290, 110)),
                )
            else:
                page_views = 1
                duration_seconds = max(
                    5,
                    int(np.random.normal(25, 12)),
                )

            session_records.append(
                {
                    "session_id": f"SES_{session_counter:09d}",
                    "user_id": user_id,
                    "session_date": marketing_row["date"],
                    "source": campaign["source_system"],
                    "medium": "paid",
                    "campaign_id": marketing_row["campaign_id"],
                    "campaign_name": marketing_row["campaign_name"],
                    "landing_page": landing_page,
                    "device_category": device,
                    "country": country,
                    "page_views": page_views,
                    "session_duration_seconds": duration_seconds,
                    "engaged_session": engaged,
                    "bounce": bounced,
                }
            )

            session_counter += 1

    return pd.DataFrame(session_records)


# ============================================================
# HUBSPOT LEADS
# ============================================================

def generate_leads(
    sessions: pd.DataFrame,
    campaigns: pd.DataFrame,
) -> pd.DataFrame:
    """Convert a percentage of GA4 sessions into HubSpot leads."""

    campaign_lookup = campaigns.set_index("campaign_id").to_dict(
        orient="index"
    )

    lead_records = []
    lead_counter = 1

    for session in sessions.to_dict(orient="records"):
        campaign = campaign_lookup[session["campaign_id"]]

        lead_probability = campaign["lead_rate"]

        if session["engaged_session"]:
            lead_probability *= 1.40

        if session["device_category"] == "desktop":
            lead_probability *= 1.15

        lead_probability = min(lead_probability, 0.40)

        if np.random.random() >= lead_probability:
            continue

        lead_date = pd.Timestamp(session["session_date"])

        mql_probability = 0.56
        sql_probability = 0.48
        customer_probability = 0.38

        is_mql = np.random.random() < mql_probability
        is_sql = is_mql and np.random.random() < sql_probability
        is_customer = is_sql and np.random.random() < customer_probability

        if is_customer:
            lifecycle_stage = "customer"
        elif is_sql:
            lifecycle_stage = "sales_qualified_lead"
        elif is_mql:
            lifecycle_stage = "marketing_qualified_lead"
        else:
            lifecycle_stage = "lead"

        company_name = (
            fake.company()
            if campaign["campaign_type"] in [
                "B2B Search",
                "B2B Lead Generation",
            ]
            else None
        )

        lead_records.append(
            {
                "lead_id": f"LEAD_{lead_counter:07d}",
                "user_id": session["user_id"],
                "session_id": session["session_id"],
                "created_date": lead_date.date().isoformat(),
                "email": fake.unique.email(),
                "first_name": fake.first_name(),
                "last_name": fake.last_name(),
                "company_name": company_name,
                "country": session["country"],
                "campaign_id": session["campaign_id"],
                "original_source": session["source"],
                "lifecycle_stage": lifecycle_stage,
                "is_mql": is_mql,
                "is_sql": is_sql,
                "is_customer": is_customer,
            }
        )

        lead_counter += 1

    return pd.DataFrame(lead_records)


# ============================================================
# SUBSCRIPTIONS
# ============================================================

def generate_subscriptions(
    leads: pd.DataFrame,
) -> pd.DataFrame:
    """Create subscriptions for leads that became customers."""

    customers = leads[leads["is_customer"]].copy()

    plan_names = [plan["plan_name"] for plan in PLANS]
    plan_probabilities = [plan["probability"] for plan in PLANS]
    plan_lookup = {
        plan["plan_name"]: plan
        for plan in PLANS
    }

    subscription_records = []

    for index, customer in enumerate(
        customers.to_dict(orient="records"),
        start=1,
    ):
        plan_name = weighted_choice(
            plan_names,
            plan_probabilities,
        )

        plan = plan_lookup[plan_name]

        lead_date = pd.Timestamp(customer["created_date"])
        delay_days = random.randint(0, 14)
        start_date = lead_date + timedelta(days=delay_days)

        # Some customers cancel during the year.
        will_cancel = np.random.random() < 0.22

        cancellation_date = None
        status = "active"

        if will_cancel:
            active_months = random.randint(1, 8)
            possible_cancellation_date = (
                start_date + pd.DateOffset(months=active_months)
            )

            if possible_cancellation_date <= pd.Timestamp(END_DATE):
                cancellation_date = possible_cancellation_date
                status = "canceled"

        subscription_records.append(
            {
                "subscription_id": f"SUB_{index:07d}",
                "customer_id": f"CUST_{index:07d}",
                "lead_id": customer["lead_id"],
                "plan_id": plan["plan_id"],
                "plan_name": plan["plan_name"],
                "monthly_price": plan["monthly_price"],
                "subscription_start_date": start_date.date().isoformat(),
                "subscription_end_date": (
                    cancellation_date.date().isoformat()
                    if cancellation_date is not None
                    else None
                ),
                "status": status,
            }
        )

    return pd.DataFrame(subscription_records)


# ============================================================
# STRIPE PAYMENTS
# ============================================================

def generate_payments(
    subscriptions: pd.DataFrame,
) -> pd.DataFrame:
    """Generate monthly payments for each subscription."""

    payment_records = []
    payment_counter = 1
    end_date = pd.Timestamp(END_DATE)

    for subscription in subscriptions.to_dict(orient="records"):
        payment_date = pd.Timestamp(
            subscription["subscription_start_date"]
        )

        subscription_end = (
            pd.Timestamp(subscription["subscription_end_date"])
            if subscription["subscription_end_date"]
            else end_date
        )

        while (
            payment_date <= subscription_end
            and payment_date <= end_date
        ):
            payment_status = weighted_choice(
                ["succeeded", "failed"],
                [0.94, 0.06],
            )

            amount = subscription["monthly_price"]

            # A small percentage of successful payments are refunded.
            refunded = (
                payment_status == "succeeded"
                and np.random.random() < 0.025
            )

            refund_amount = amount if refunded else 0.00

            payment_records.append(
                {
                    "payment_id": f"PAY_{payment_counter:09d}",
                    "subscription_id": subscription["subscription_id"],
                    "customer_id": subscription["customer_id"],
                    "payment_date": payment_date.date().isoformat(),
                    "amount": amount,
                    "currency": "USD",
                    "payment_status": payment_status,
                    "refunded": refunded,
                    "refund_amount": refund_amount,
                    "net_revenue": (
                        round(amount - refund_amount, 2)
                        if payment_status == "succeeded"
                        else 0.00
                    ),
                }
            )

            payment_counter += 1
            payment_date += pd.DateOffset(months=1)

    return pd.DataFrame(payment_records)


# ============================================================
# COURSE ENROLLMENTS
# ============================================================

def generate_enrollments(
    subscriptions: pd.DataFrame,
) -> pd.DataFrame:
    """Generate LearnLoop course enrollments."""

    enrollment_records = []
    enrollment_counter = 1

    for subscription in subscriptions.to_dict(orient="records"):
        number_of_courses = weighted_choice(
            [1, 2, 3, 4],
            [0.38, 0.34, 0.20, 0.08],
        )

        selected_courses = random.sample(
            COURSES,
            k=min(number_of_courses, len(COURSES)),
        )

        subscription_start = pd.Timestamp(
            subscription["subscription_start_date"]
        )

        for course in selected_courses:
            enrollment_date = subscription_start + timedelta(
                days=random.randint(0, 60)
            )

            if enrollment_date > pd.Timestamp(END_DATE):
                continue

            completion_probability = {
                "Starter": 0.45,
                "Professional": 0.58,
                "Enterprise": 0.68,
            }[subscription["plan_name"]]

            completed = (
                np.random.random() < completion_probability
            )

            progress_percentage = (
                100
                if completed
                else random.randint(5, 95)
            )

            enrollment_records.append(
                {
                    "enrollment_id": f"ENR_{enrollment_counter:08d}",
                    "customer_id": subscription["customer_id"],
                    "subscription_id": subscription["subscription_id"],
                    "course_id": course["course_id"],
                    "course_name": course["course_name"],
                    "course_category": course["category"],
                    "enrollment_date": enrollment_date.date().isoformat(),
                    "progress_percentage": progress_percentage,
                    "completed": completed,
                }
            )

            enrollment_counter += 1

    return pd.DataFrame(enrollment_records)


# ============================================================
# EXPORT
# ============================================================

def export_datasets(
    campaigns: pd.DataFrame,
    marketing: pd.DataFrame,
    sessions: pd.DataFrame,
    leads: pd.DataFrame,
    subscriptions: pd.DataFrame,
    payments: pd.DataFrame,
    enrollments: pd.DataFrame,
) -> None:
    """Export source datasets as paginated JSON files only."""

    google_ads = marketing[
        marketing["source_system"] == "google_ads"
    ].copy()

    meta_ads = marketing[
        marketing["source_system"] == "meta_ads"
    ].copy()

    clear_generated_json_files()

    datasets = [
        (
            google_ads,
            RAW_DIR / "google_ads",
            "campaign_performance",
        ),
        (
            meta_ads,
            RAW_DIR / "meta_ads",
            "campaign_performance",
        ),
        (
            sessions,
            RAW_DIR / "ga4",
            "sessions",
        ),
        (
            leads,
            RAW_DIR / "hubspot",
            "contacts",
        ),
        (
            subscriptions,
            RAW_DIR / "stripe",
            "subscriptions",
        ),
        (
            payments,
            RAW_DIR / "stripe",
            "payments",
        ),
        (
            enrollments,
            RAW_DIR / "learnloop",
            "course_enrollments",
        ),
    ]

    for dataframe, output_dir, file_prefix in datasets:
        created_files = save_json_records(
            dataframe=dataframe,
            output_dir=output_dir,
            file_prefix=file_prefix,
        )

        print(
            f"Created {len(created_files):,} JSON file(s) "
            f"for {file_prefix}."
        )


# ============================================================
# VALIDATION
# ============================================================

def validate_data(
    sessions: pd.DataFrame,
    leads: pd.DataFrame,
    subscriptions: pd.DataFrame,
    payments: pd.DataFrame,
) -> None:
    """Run basic referential-integrity validations."""

    invalid_lead_sessions = ~leads["session_id"].isin(
        sessions["session_id"]
    )

    invalid_subscription_leads = ~subscriptions["lead_id"].isin(
        leads["lead_id"]
    )

    invalid_payment_subscriptions = ~payments[
        "subscription_id"
    ].isin(subscriptions["subscription_id"])

    assert invalid_lead_sessions.sum() == 0, (
        "Some leads do not have valid sessions."
    )

    assert invalid_subscription_leads.sum() == 0, (
        "Some subscriptions do not have valid leads."
    )

    assert invalid_payment_subscriptions.sum() == 0, (
        "Some payments do not have valid subscriptions."
    )


# ============================================================
# MAIN PIPELINE
# ============================================================

def main() -> None:
    create_directories()

    print("Generating campaigns...")
    campaigns = generate_campaigns()

    print("Generating Google Ads and Meta Ads data...")
    marketing = generate_marketing_performance(campaigns)

    print("Generating GA4 sessions...")
    sessions = generate_sessions(marketing, campaigns)

    print("Generating HubSpot leads...")
    leads = generate_leads(sessions, campaigns)

    print("Generating Stripe subscriptions...")
    subscriptions = generate_subscriptions(leads)

    print("Generating Stripe payments...")
    payments = generate_payments(subscriptions)

    print("Generating course enrollments...")
    enrollments = generate_enrollments(subscriptions)

    print("Validating relationships...")
    validate_data(
        sessions,
        leads,
        subscriptions,
        payments,
    )

    print("Exporting datasets...")
    export_datasets(
        campaigns,
        marketing,
        sessions,
        leads,
        subscriptions,
        payments,
        enrollments,
    )

    print("\nGeneration completed successfully.")
    print(f"Marketing rows: {len(marketing):,}")
    print(f"GA4 sessions: {len(sessions):,}")
    print(f"HubSpot leads: {len(leads):,}")
    print(f"Customers: {leads['is_customer'].sum():,}")
    print(f"Subscriptions: {len(subscriptions):,}")
    print(f"Payments: {len(payments):,}")
    print(f"Enrollments: {len(enrollments):,}")
    print(
        f"Net revenue: ${payments['net_revenue'].sum():,.2f}"
    )


if __name__ == "__main__":
    main()