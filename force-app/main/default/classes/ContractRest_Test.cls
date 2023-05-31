@isTest
public class ContractRest_Test {
  static final String REQUEST_URI = '/services/apexrest/Contract/';

  @isTest static void testContractInsertPass() {
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();

    Account account = new Account(
      Name = 'AccountTest',
      Industry = 'Banking'
    );
    insert account;

    Contract contract = new Contract(
      Status = 'Draft',
      ContractTerm = 12,
      StartDate = Date.today(),
      AccountId = account.Id
    );
    
    req.requestURI = REQUEST_URI;
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueOf(JSON.serializePretty(contract));

    RestContext.request = req;
    RestContext.response= res;

    Test.startTest();
    ContractRest.insertContract();
    Test.stopTest();

    List<Contract> newContractCreated = [SELECT Id, Status, ContractTerm, StartDate FROM Contract];
    System.assertEquals(1, newContractCreated.size());
    Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(res.responseBody.toString());
    System.assertEquals(true, (Boolean)responseBody.get('success'));
    System.assertEquals(newContractCreated[0].Id, (String)responseBody.get('id'));
    System.assertEquals(201, res.statusCode);
  }

  @isTest static void testContractInsertFail() {
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();

    Contract contract = new Contract(
      Status = 'Draft',
      ContractTerm = 12,
      StartDate = Date.today()
    );
    
    req.requestURI = REQUEST_URI;
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueOf(JSON.serializePretty(contract));

    RestContext.request = req;
    RestContext.response= res;

    Test.startTest();
    ContractRest.insertContract();
    Test.stopTest();

    List<Contract> newContractCreated = [SELECT Id, Status, ContractTerm, StartDate FROM Contract];
    System.assertEquals(0, newContractCreated.size());
    Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(res.responseBody.toString());
    System.assertEquals(false, (Boolean)responseBody.get('success'));
    System.assertEquals(null, (String)responseBody.get('id'));
    System.assertEquals(500, res.statusCode);
  }

  @isTest static void testContractUpdatePass() {
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();

    Account account = new Account(
      Name = 'AccountTest',
      Industry = 'Banking'
    );
    insert account;

    Contract contract = new Contract(
      Status = 'Draft',
      ContractTerm = 12,
      StartDate = Date.today(),
      AccountId = account.Id
    );
    insert contract;

    Contract contractToUpdate = new Contract(
      Status = 'Draft',
      ContractTerm = 20,
      StartDate = Date.today(),
      AccountId = account.Id
    );
    
    req.requestURI = REQUEST_URI + contract.Id;
    req.httpMethod = 'PATCH';
    req.requestBody = Blob.valueOf(JSON.serializePretty(contractToUpdate));

    RestContext.request = req;
    RestContext.response= res;

    Test.startTest();
    ContractRest.updateContract();
    Test.stopTest();

    Contract contractUpdated = [SELECT Id, Status, ContractTerm, StartDate FROM Contract WHERE Id = :contract.Id];
    System.assertNotEquals(null, contractUpdated);
    System.assertEquals(20, contractUpdated.ContractTerm);
    Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(res.responseBody.toString());
    System.assertEquals(true, (Boolean)responseBody.get('success'));
    System.assertEquals(contract.Id, (String)responseBody.get('id'));
    System.assertEquals(200, res.statusCode);
  }

  @isTest static void testContractUpdateFail() {
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();

    Account account = new Account(
      Name = 'AccountTest',
      Industry = 'Banking'
    );
    insert account;

    Contract contract = new Contract(
      Status = 'Draft',
      ContractTerm = 12,
      StartDate = Date.today(),
      AccountId = account.Id
    );
    insert contract;

    Contract contractToUpdate = new Contract(
      Status = 'Inconnu',
      ContractTerm = 20,
      StartDate = Date.today()
    );
    
    req.requestURI = REQUEST_URI + contract.Id;
    req.httpMethod = 'PATCH';
    req.requestBody = Blob.valueOf(JSON.serializePretty(contractToUpdate));

    RestContext.request = req;
    RestContext.response= res;

    Test.startTest();
    ContractRest.updateContract();
    Test.stopTest();

    Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(res.responseBody.toString());
    System.assertEquals(false, (Boolean)responseBody.get('success'));
    System.assertEquals(null, (String)responseBody.get('id'));
    System.assertEquals(500, res.statusCode);
  }

  @isTest static void testContractUpdateWrongId() {
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();

    Contract contractToUpdate = new Contract(
      Status = 'Draft',
      ContractTerm = 20,
      StartDate = Date.today()
    );
    
    req.requestURI = REQUEST_URI + 'ABCD12';
    req.httpMethod = 'PATCH';
    req.requestBody = Blob.valueOf(JSON.serializePretty(contractToUpdate));

    RestContext.request = req;
    RestContext.response= res;

    Test.startTest();
    ContractRest.updateContract();
    Test.stopTest();

    Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(res.responseBody.toString());
    System.assertEquals(false, (Boolean)responseBody.get('success'));
    System.assertEquals(null, (String)responseBody.get('id'));
    System.assertEquals(500, res.statusCode);
  }
}