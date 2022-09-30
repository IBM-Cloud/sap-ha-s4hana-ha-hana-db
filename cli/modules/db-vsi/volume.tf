
resource "ibm_is_volume" "vol" {

count = length( var.VOLUME_SIZES )
  name		= lower("${local.HOSTNAME}-vol${count.index}")
  zone		= var.ZONE
  resource_group = data.ibm_resource_group.group.id
  capacity	= var.VOLUME_SIZES[count.index]
  profile	= var.VOL_PROFILE
  iops		= var.VOL_IOPS
}

resource "ibm_is_instance_volume_attachment" "vol-attach0" {
  for_each = local.vol0
  instance = ibm_is_instance.vsi[0].id
  volume = ibm_is_volume.vol[each.key].id
}

resource "ibm_is_instance_volume_attachment" "vol-attach1" {
  for_each = local.vol1
  instance = ibm_is_instance.vsi[1].id
  volume = ibm_is_volume.vol[each.key].id
}
