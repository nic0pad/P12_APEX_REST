@RestResource(urlMapping='/Contract/*')
global with sharing class ContractRest {
  @HttpPost
  global static void insertContract() {
    RestManager restManager = new RestManager(RestContext.request, RestContext.response, 'Contract');

    Contract contract = new Contract();

    try {
      restManager.populateFields(contract);
      insert contract;
      restManager.response(contract.Id, 201);
    } catch(Exception e) {
      restManager.responseWithErrors(e);
    }
  }

  @HttpPatch
  global static void updateContract() {
    RestManager restManager = new RestManager(RestContext.request, RestContext.response, 'Contract');

    String contractId = restManager.getId();

    try {
      Contract contract = [SELECT Id FROM Contract WHERE Id = :contractId];
      restManager.populateFields(contract);

      update contract;
      restManager.response(contract.Id, 200);
    } catch(Exception e) {
      restManager.responseWithErrors(e);
    }
  }
}