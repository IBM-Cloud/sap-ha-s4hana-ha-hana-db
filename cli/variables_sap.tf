##############################################################
# The variables and data sources used in SAP Ansible Modules.
##############################################################

variable "hana_sid" {
	type		= string
	description = "hana_sid"
	default		= "HDB"
	validation {
		condition     = length(regexall("^[a-zA-Z][a-zA-Z0-9][a-zA-Z0-9]$", var.hana_sid)) > 0
		error_message = "The hana_sid is not valid."
	}
}

variable "sap_ascs_instance_number" {
	type		= string
	description = "sap_ascs_instance_number"
	default		= "00"
	validation {
		condition     = var.sap_ascs_instance_number >= 0 && var.sap_ascs_instance_number <=97
		error_message = "The sap_ascs_instance_number is not valid."
	}
}

variable "sap_ers_instance_number" {
	type		= string
	description = "sap_ers_instance_number"
	default		= "01"
	validation {
		condition     = var.sap_ers_instance_number >= 00 && var.sap_ers_instance_number <=99
		error_message = "The sap_ers_instance_number is not valid."
	}
}

variable "sap_ci_instance_number" {
	type		= string
	description = "sap_ci_instance_number"
	default		= "10"
	validation {
		condition     = var.sap_ci_instance_number >= 00 && var.sap_ci_instance_number <=99
		error_message = "The sap_ci_instance_number is not valid."
	}
}

variable "sap_aas_instance_number" {
	type		= string
	description = "sap_aas_instance_number"
	default		= "20"
	validation {
		condition     = var.sap_aas_instance_number >= 00 && var.sap_aas_instance_number <=99
		error_message = "The sap_aas_instance_number is not valid."
	}
}

variable "hana_sysno" {
	type		= string
	description = "hana_sysno"
	default		= "00"
	validation {
		condition     = var.hana_sysno >= 0 && var.hana_sysno <=97
		error_message = "The hana_sysno is not valid."
	}
}

variable "hana_main_password" {
	type		= string
	sensitive = true
	description = "HANADB main password"
	validation {
		condition     = length(regexall("^(.{0,7}|.{15,}|[^0-9a-zA-Z]*)$", var.hana_main_password)) == 0 && length(regexall("^[^0-9_][0-9a-zA-Z!@#$_]+$", var.hana_main_password)) > 0
		error_message = "The hana_main_password is not valid."
	}
}

variable "hana_system_usage" {
	type		= string
	description = "hana_system_usage"
	default		= "custom"
	validation {
		condition     = contains(["production", "test", "development", "custom" ], var.hana_system_usage )
		error_message = "The hana_system_usage must be one of: production, test, development, custom."
	}
}

variable "hana_components" {
	type		= string
	description = "hana_components"
	default		= "server"
	validation {
		condition     = contains(["all", "client", "es", "ets", "lcapps", "server", "smartda", "streaming", "rdsync", "xs", "studio", "afl", "sca", "sop", "eml", "rme", "rtl", "trp" ], var.hana_components )
		error_message = "The hana_components must be one of: all, client, es, ets, lcapps, server, smartda, streaming, rdsync, xs, studio, afl, sca, sop, eml, rme, rtl, trp."
	}
}

variable "kit_saphana_file" {
	type		= string
	description = "kit_saphana_file"
	default		= "51054623.ZIP"
}

variable "sap_sid" {
	type		= string
	description = "sap_sid"
	default		= "S4A"
	validation {
		condition     = length(regexall("^[a-zA-Z][a-zA-Z0-9][a-zA-Z0-9]$", var.sap_sid)) > 0
		error_message = "The sap_sid is not valid."
	}
}

variable "sap_main_password" {
	type		= string
	sensitive = true
	description = "SAP main password"
	validation {
		condition     = length(regexall("^(.{0,9}|.{15,}|[^0-9]*)$", var.sap_main_password)) == 0 && length(regexall("^[^0-9_][0-9a-zA-Z@#$_]+$", var.sap_main_password)) > 0
		error_message = "The sap_main_password is not valid."
	}
}

variable "ha_password" {
	type		= string
	sensitive = true
	description = "HA cluster password"
	validation {
		condition     = length(regexall("^(.{0,9}|.{15,}|[^0-9]*)$", var.ha_password)) == 0 && length(regexall("^[^0-9_][0-9a-zA-Z@#$_]+$", var.ha_password)) > 0
		error_message = "The ha_password is not valid."
	}
}

variable "hdb_concurrent_jobs" {
	type		= string
	description = "hdb_concurrent_jobs"
	default		= "23"
	validation {
		condition     = var.hdb_concurrent_jobs >= 1 && var.hdb_concurrent_jobs <=25
		error_message = "The hdb_concurrent_jobs is not valid."
	}
}

variable "kit_sapcar_file" {
	type		= string
	description = "kit_sapcar_file"
	default		= "SAPCAR_1010-70006178.EXE"
}

variable "kit_swpm_file" {
	type		= string
	description = "kit_swpm_file"
	default		= "SWPM20SP09_4-80003424.SAR"
}

variable "kit_sapexe_file" {
	type		= string
	description = "kit_sapexe_file"
	default		= "SAPEXE_100-70005283.SAR"
}

variable "kit_sapexedb_file" {
	type		= string
	description = "kit_sapexedb_file"
	default		= "SAPEXEDB_100-70005282.SAR"
}

variable "kit_igsexe_file" {
	type		= string
	description = "kit_igsexe_file"
	default		= "igsexe_1-70005417.sar"
}

variable "kit_igshelper_file" {
	type		= string
	description = "kit_igshelper_file"
	default		= "igshelper_17-10010245.sar"
}

variable "kit_saphotagent_file" {
	type		= string
	description = "kit_saphotagent_file"
	default		= "SAPHOSTAGENT51_51-20009394.SAR"
}

variable "kit_hdbclient_file" {
	type		= string
	description = "kit_hdbclient_file"
	default		= "IMDB_CLIENT20_009_28-80002082.SAR"
}

variable "kit_s4hana_export" {
	type		= string
	description = "kit_s4hana_export"
	default		= "/S4HANA/export"
}
