
pragma solidity ^0.5.0;

contract BuilderShop {
   address[] builderInstances;
   uint contractId = 0;

   //clubphysique registry is hard coded
   address clubphysiqueRegistryContract = '';

   modifier onlyValidSender() {
       ClubphysiqueRegistry nftg_registry = ClubphysiqueRegistry(clubphysiqueRegistryContract);
       bool is_valid = nftg_registry.isValidClubphysiqueSender(msg.sender);
       require(is_valid==true);
       _;
   }

   mapping (address => bool) public BuilderShops;

   function isValidBuilderShop(address builder_shop) public view returns (bool isValid) {
       //public function, allowing anyone to check if a contract address is a valid clubphysique gateway contract
       return(BuilderShops[builder_shop]);
   }

   event BuilderInstanceCreated(address new_contract_address, uint contractId);

   function createNewBuilderInstance(
       string memory _name,
       string memory _symbol,
       uint num_nifties,
       string memory token_base_uri,
       string memory creator_name)
       public returns (ClubphysiqueBuilderInstance tokenAddress) { // <- must replace this !!!
   //public onlyValidSender returns (ClubphysiqueBuilderInstance tokenAddress) {

       contractId = contractId + 1;

       ClubphysiqueBuilderInstance new_contract = new ClubphysiqueBuilderInstance(
           _name,
           _symbol,
           contractId,
           num_nifties,
           token_base_uri,
           creator_name
       );

       address externalId = address(new_contract);

       BuilderShops[externalId] = true;

       emit BuilderInstanceCreated(externalId, contractId);

       return (new_contract);
    }
}
