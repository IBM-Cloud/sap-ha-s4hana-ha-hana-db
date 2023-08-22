##############################################################
# The variables and data sources used in SAP Ansible Modules.
##############################################################

variable "HANA_SID" {
	type		= string
	description = "HANA_SID"
	default		= "HDB"
	validation {
		condition     = length(regexall("^[a-zA-Z][a-zA-Z0-9][a-zA-Z0-9]$", var.HANA_SID)) > 0
		error_message = "The HANA_SID is not valid."
	}
}

variable "SAP_ASCS_INSTANCE_NUMBER" {
	type		= string
	description = "SAP_ASCS_INSTANCE_NUMBER"
	default		= "00"
	validation {
		condition     = var.SAP_ASCS_INSTANCE_NUMBER >= 0 && var.SAP_ASCS_INSTANCE_NUMBER <=97
		error_message = "The SAP_ASCS_INSTANCE_NUMBER is not valid."
	}
}

variable "SAP_ERS_INSTANCE_NUMBER" {
	type		= string
	description = "SAP_ERS_INSTANCE_NUMBER"
	default		= "01"
	validation {
		condition     = var.SAP_ERS_INSTANCE_NUMBER >= 00 && var.SAP_ERS_INSTANCE_NUMBER <=99
		error_message = "The SAP_ERS_INSTANCE_NUMBER is not valid."
	}
}

variable "SAP_CI_INSTANCE_NUMBER" {
	type		= string
	description = "SAP_CI_INSTANCE_NUMBER"
	default		= "10"
	validation {
		condition     = var.SAP_CI_INSTANCE_NUMBER >= 00 && var.SAP_CI_INSTANCE_NUMBER <=99
		error_message = "The SAP_CI_INSTANCE_NUMBER is not valid."
	}
}

variable "SAP_AAS_INSTANCE_NUMBER" {
	type		= string
	description = "SAP_AAS_INSTANCE_NUMBER"
	default		= "20"
	validation {
		condition     = var.SAP_AAS_INSTANCE_NUMBER >= 00 && var.SAP_AAS_INSTANCE_NUMBER <=99
		error_message = "The SAP_AAS_INSTANCE_NUMBER is not valid."
	}
}

variable "HANA_SYSNO" {
	type		= string
	description = "HANA_SYSNO"
	default		= "00"
	validation {
		condition     = var.HANA_SYSNO >= 0 && var.HANA_SYSNO <=97
		error_message = "The HANA_SYSNO is not valid."
	}
}

variable "HANA_MAIN_PASSWORD" {
	type		= string
	sensitive = true
	description = "HANADB main password"
	validation {
		condition     = length(regexall("^(.{0,7}|.{15,}|[^0-9a-zA-Z]*)$", var.HANA_MAIN_PASSWORD)) == 0 && length(regexall("^[^0-9_][0-9a-zA-Z!@#$_]+$", var.HANA_MAIN_PASSWORD)) > 0
		error_message = "The HANA_MAIN_PASSWORD is not valid."
	}
}

variable "HANA_SYSTEM_USAGE" {
	type		= string
	description = "HANA_SYSTEM_USAGE"
	default		= "custom"
	validation {
		condition     = contains(["production", "test", "development", "custom" ], var.HANA_SYSTEM_USAGE )
		error_message = "The HANA_SYSTEM_USAGE must be one of: production, test, development, custom."
	}
}

variable "HANA_COMPONENTS" {
	type		= string
	description = "HANA_COMPONENTS"
	default		= "server"
	validation {
		condition     = contains(["all", "client", "es", "ets", "lcapps", "server", "smartda", "streaming", "rdsync", "xs", "studio", "afl", "sca", "sop", "eml", "rme", "rtl", "trp" ], var.HANA_COMPONENTS )
		error_message = "The HANA_COMPONENTS must be one of: all, client, es, ets, lcapps, server, smartda, streaming, rdsync, xs, studio, afl, sca, sop, eml, rme, rtl, trp."
	}
}

variable "KIT_SAPHANA_FILE" {
	type		= string
	description = "KIT_SAPHANA_FILE"
	default		= "51055299.ZIP"
}

variable "SAP_SID" {
	type		= string
	description = "SAP_SID"
	default		= "S4A"
	validation {
		condition     = length(regexall("^[a-zA-Z][a-zA-Z0-9][a-zA-Z0-9]$", var.SAP_SID)) > 0
		error_message = "The SAP_SID is not valid."
	}
}

variable "SAP_MAIN_PASSWORD" {
	type		= string
	sensitive = true
	description = "SAP main password"
	validation {
		condition     = length(regexall("^(.{0,9}|.{15,}|[^0-9]*)$", var.SAP_MAIN_PASSWORD)) == 0 && length(regexall("^[^0-9_][0-9a-zA-Z@#$_]+$", var.SAP_MAIN_PASSWORD)) > 0
		error_message = "The SAP_MAIN_PASSWORD is not valid."
	}
}

variable "HA_PASSWORD" {
	type		= string
	sensitive = true
	description = "HA cluster password"
	validation {
		condition     = length(regexall("^(.{0,9}|.{15,}|[^0-9]*)$", var.HA_PASSWORD)) == 0 && length(regexall("^[^0-9_][0-9a-zA-Z@#$_]+$", var.HA_PASSWORD)) > 0
		error_message = "The HA_PASSWORD is not valid."
	}
}

variable "HDB_CONCURRENT_JOBS" {
	type		= string
	description = "HDB_CONCURRENT_JOBS"
	default		= "23"
	validation {
		condition     = var.HDB_CONCURRENT_JOBS >= 1 && var.HDB_CONCURRENT_JOBS <=25
		error_message = "The HDB_CONCURRENT_JOBS is not valid."
	}
}

variable "KIT_SAPCAR_FILE" {
	type		= string
	description = "KIT_SAPCAR_FILE"
	default		= "SAPCAR_1010-70006178.EXE"
}

variable "KIT_SWPM_FILE" {
	type		= string
	description = "KIT_SWPM_FILE"
	default		= "SWPM20SP09_4-80003424.SAR"
}

variable "KIT_SAPEXE_FILE" {
	type		= string
	description = "KIT_SAPEXE_FILE"
	default		= "SAPEXE_100-70005283.SAR"
}

variable "KIT_SAPEXEDB_FILE" {
	type		= string
	description = "KIT_SAPEXEDB_FILE"
	default		= "SAPEXEDB_100-70005282.SAR"
}

variable "KIT_IGSEXE_FILE" {
	type		= string
	description = "KIT_IGSEXE_FILE"
	default		= "igsexe_1-70005417.sar"
}

variable "KIT_IGSHELPER_FILE" {
	type		= string
	description = "KIT_IGSHELPER_FILE"
	default		= "igshelper_17-10010245.sar"
}

variable "KIT_SAPHOSTAGENT_FILE" {
	type		= string
	description = "KIT_SAPHOSTAGENT_FILE"
	default		= "SAPHOSTAGENT51_51-20009394.SAR"
}

variable "KIT_HDBCLIENT_FILE" {
	type		= string
	description = "KIT_HDBCLIENT_FILE"
	default		= "IMDB_CLIENT20_009_28-80002082.SAR"
}

variable "KIT_S4HANA_EXPORT" {
	type		= string
	description = "KIT_S4HANA_EXPORT"
	default		= "/S4HANA/export"
}
