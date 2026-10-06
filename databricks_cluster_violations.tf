terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = ">= 1.40.0"
    }
  }
}

provider "databricks" {
  host = "https://adb-1234567890123456.7.azuredatabricks.net"
}

resource "databricks_cluster" "dev_autoscale_cluster" {
  cluster_name            = "dev-autoscale-cluster"
  spark_version           = "13.3.x-photon-scala2.12"
  node_type_id            = "Standard_DS3_v2"
  autotermination_minutes = 0

  autoscale {
    min_workers = 1
    max_workers = 20
  }

  azure_attributes {
    availability       = "ON_DEMAND_AZURE"
    first_on_demand    = 1
    spot_bid_max_price = -1
  }

  custom_tags = {
    environment = "dev"
    owner       = "data-platform"
  }
}

resource "databricks_cluster" "test_fixed_cluster" {
  cluster_name            = "test-fixed-cluster"
  spark_version           = "13.3.x-scala2.12"
  runtime_engine          = "PHOTON"
  node_type_id            = "i3.xlarge"
  autotermination_minutes = 240
  num_workers             = 10

  aws_attributes {
    availability    = "ON_DEMAND"
    first_on_demand = 1
    zone_id         = "us-east-1a"
  }

  custom_tags = {
    env   = "test"
    owner = "data-platform"
  }
}
