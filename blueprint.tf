# Refer https://github.com/hashicorp/terraform/issues/22263 on how to produce map from nested for loop

locals {
	nsg_rules = flatten([
		for each in var.nsg_rules_table : [
			for rule in concat(each.nsg_inbound, each.nsg_outbound) : {
				"${each.nsg_name}-${rule[1]}-${rule[2]}" = {
					nsg_name = each.nsg_name
					nsg_rule = rule
				}
			}
		]
	])
	
	nsg_rules_map = { 
		for item in local.nsg_rules:
			keys(item)[0] => values(item)[0]
	}
}

/*
output "nsg_rules" {
	value = local.nsg_rules_map
}
*/

resource "azurerm_network_security_rule" "inbound" {
  for_each                			= local.nsg_rules_map
  
	name		                			= each.value.nsg_rule[0]
	priority                			= each.value.nsg_rule[1]
	direction		            			= each.value.nsg_rule[2]
	access			            			= each.value.nsg_rule[3]
	protocol		            			= each.value.nsg_rule[4]
	source_port_range       			= each.value.nsg_rule[5]
	source_port_ranges      			= each.value.nsg_rule[6]
	source_address_prefix   			= each.value.nsg_rule[7]
	source_address_prefixes 			= each.value.nsg_rule[8]
	destination_port_range  			= each.value.nsg_rule[9]
	destination_port_ranges 			= each.value.nsg_rule[10]
	destination_address_prefix	 	= each.value.nsg_rule[11]
	destination_address_prefixes 	= each.value.nsg_rule[12]

  resource_group_name     			= var.rg
  network_security_group_name		= each.value.nsg_name
}
