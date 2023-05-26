@RestResource(urlMapping='/Contract/*')
global with sharing class ContractRest {
  @HttpPost
  global static void insertContract() {
    RestManager restManager = new RestManager(RestContext.request, RestContext.response, 'Contract');

    Contract contract = new Contract();
    restManager.populateFields(contract);

    try {
      insert contract;
      restManager.response(contract.Id);
    } catch(Exception e) {
      restManager.responseWithErrors(e);
    }
  }

  @HttpPatch
  global static void updateContract() {
    RestManager restManager = new RestManager(RestContext.request, RestContext.response, 'Contract');

    String contractId = restManager.getId();

    Contract contract = [SELECT Id FROM Contract WHERE Id = :contractId];
    restManager.populateFields(contract);

    try {
      update contract;
      restManager.response(contract.Id);
    } catch(Exception e) {
      restManager.responseWithErrors(e);
    }
  }
}