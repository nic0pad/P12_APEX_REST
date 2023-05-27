@RestResource(urlMapping='/Contract/*')
global with sharing class ContractRest {
  static final String OBJECT_TYPE = 'Contract';

  @HttpPost
  global static void insertContract() {
    RestManager restManager = new RestManager(RestContext.request, RestContext.response, OBJECT_TYPE);

    try {
      Contract contract = (Contract)restManager.getObject();
      insert contract;
      restManager.response(contract.Id, 201);
    } catch(Exception e) {
      restManager.responseWithErrors(e);
    }
  }

  @HttpPatch
  global static void updateContract() {
    RestManager restManager = new RestManager(RestContext.request, RestContext.response, OBJECT_TYPE);

    try {
      String contractId = restManager.getId();

      List<Contract> contracts = [SELECT Id FROM Contract WHERE Id = :contractId];
      if (contracts.size() == 1) {
        Contract contract = (Contract)restManager.getObject();
        update contract;
        restManager.response(contract.Id, 200);
      } else {
        throw new RestException('Invalid Id, contract not found.');
      }
    } catch(Exception e) {
      restManager.responseWithErrors(e);
    }
  }
}