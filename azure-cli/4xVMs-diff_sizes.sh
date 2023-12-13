# Create the virtual network
az network vnet create -g myResourceGroup -n iAr -n subnets -l 10.0.0.0/16

# Create the network interfaces
for vmIndex in 0..4; do
  vmSize=$(echo "Standard_D2s_v3 Standard_D4s_v3 Standard_D8s_v3 Standard_D16s_v3" | cut -d " " -f $vmIndex)
  networkInterfaceName=$(echo "vm${vmIndex}")

  az network nic create -g myResourceGroup -n ${networkInterfaceName} -n iAr --subnet subnet
done

# Create the virtual machines
for vmIndex in 0..4; do
  vmSize=$(echo "Standard_D2s_v3 Standard_D4s_v3 Standard_D8s_v3 Standard_D16s_v3" | cut -d " " -f $vmIndex)
  vmName=$(echo "vm${vmIndex}")

  az vm create -g myResourceGroup -n ${vmName} -n iAr --subnet subnet --vm-size ${vmSize}
done
#
