@isTest
public class ContactRest_Test {
  static final String REQUEST_URI = '/services/apexrest/Contact/';
  @isTest static void testContactInsertPass() {
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();

    Contact contact = new Contact(
      FirstName = 'John',
      LastName = 'Doe',
      Email='john@doe.com'
    );

    req.requestURI = REQUEST_URI;
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueOf(JSON.serializePretty(contact));

    RestContext.request = req;
    RestContext.response= res;

    Test.startTest();
    ContactRest.insertContact();
    Test.stopTest();

    Contact newContactCreated = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE Email = 'john@doe.com' LIMIT 1];
    System.assertNotEquals(null, newContactCreated);
    Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(res.responseBody.toString());
    System.assertEquals(true, (Boolean)responseBody.get('success'));
    System.assertEquals(newContactCreated.Id, (String)responseBody.get('id'));
    System.assertEquals(201, res.statusCode);
  }

  @isTest static void testContactInsertFail() {
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();

    Contact contact = new Contact(
      FirstName = 'John',
      Email='john@doe.com'
    );
    
    req.requestURI = REQUEST_URI;
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueOf(JSON.serializePretty(contact));
        
    RestContext.request = req;
    RestContext.response= res;
    
    Test.startTest();
    ContactRest.insertContact();
    Test.stopTest();

    List<Contact> newContactCreated = [SELECT Id, FirstName, LastName, Email FROM Contact 
      WHERE LastName = 'Doe' AND FirstName = 'John'];
    System.assertEquals(true, newContactCreated.isEmpty());
    Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(res.responseBody.toString());
    System.assertEquals(false, (Boolean)responseBody.get('success'));
    System.assertEquals(null, responseBody.get('id'));
    System.assertEquals(500, res.statusCode);
  }

  @isTest static void testContactInsertExisting() {
    //Create contact
    Contact contact = new Contact(
      FirstName = 'John',
      LastName = 'Doe',
      Email='john@doe.com'
    );
    insert contact;

    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();

    Contact contactToCreate = new Contact(
      FirstName = 'John',
      LastName = 'Doe',
      Email='john@doe.com'
    );
    
    req.requestURI = REQUEST_URI;
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueOf(JSON.serializePretty(contactToCreate));
        
    RestContext.request = req;
    RestContext.response= res;
    
    Test.startTest();
    ContactRest.insertContact();
    Test.stopTest();

    Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(res.responseBody.toString());
    System.assertEquals(true, (Boolean)responseBody.get('success'));
    System.assertEquals(contact.Id, responseBody.get('id'));
    System.assertEquals(200, res.statusCode);
  }
  
  @isTest static void testContactUpdatePass() {
    //Create contact
    Contact contact = new Contact(
      FirstName = 'John',
      LastName = 'Doe',
      Email='john@doe.com'
    );
    insert contact;

    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();

    Contact contactToUpdate = new Contact(
      FirstName = 'Marc',
      LastName = 'Doe',
      Email='marc@doe.com'
    );
    
    req.requestURI = REQUEST_URI + contact.Id;
    req.httpMethod = 'PATCH';
    req.requestBody = Blob.valueOf(JSON.serializePretty(contactToUpdate));
 
    RestContext.request = req;
    RestContext.response= res;
    
    Test.startTest();
    ContactRest.updateContact();
    Test.stopTest();

    Contact contactUpdated = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE Id = :contact.Id];
    System.assertNotEquals(null, contactUpdated);
    System.assertEquals('Marc', contactUpdated.FirstName);
    System.assertEquals('Doe', contactUpdated.LastName);
    System.assertEquals('marc@doe.com', contactUpdated.Email);
    Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(res.responseBody.toString());
    System.assertEquals(true, (Boolean)responseBody.get('success'));
    System.assertEquals(contact.Id, (String)responseBody.get('id'));
    System.assertEquals(200, res.statusCode);
  }

  @isTest static void testContactUpdateFail() {
    //Create contact
    Contact contact = new Contact(
      FirstName = 'John',
      LastName = 'Doe',
      Email='john@doe.com'
    );
    insert contact;

    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();

    Contact contactToUpdate = new Contact(
      FirstName = 'Marc',
      LastName = 'Doe',
      Email='marc'
    );
    
    req.requestURI = REQUEST_URI + contact.Id;
    req.httpMethod = 'PATCH';
    req.requestBody = Blob.valueOf(JSON.serializePretty(contactToUpdate));
 
    RestContext.request = req;
    RestContext.response= res;
    
    Test.startTest();
    ContactRest.updateContact();
    Test.stopTest();

    Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(res.responseBody.toString());
    System.assertEquals(false, (Boolean)responseBody.get('success'));
    System.assertEquals(null, (String)responseBody.get('id'));
    System.assertEquals(500, res.statusCode);
  }

  @isTest static void testContactUpdateWrongId() {
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();

    Contact contactToUpdate = new Contact(
      FirstName = 'Marc',
      LastName = 'Doe',
      Email='marc@doe.com'
    );
    
    req.requestURI = REQUEST_URI + 'AACD';
    req.httpMethod = 'PATCH';
    req.requestBody = Blob.valueOf(JSON.serializePretty(contactToUpdate));
 
    RestContext.request = req;
    RestContext.response= res;
    
    Test.startTest();
    ContactRest.updateContact();
    Test.stopTest();

    Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(res.responseBody.toString());
    System.assertEquals(false, (Boolean)responseBody.get('success'));
    System.assertEquals(null, (String)responseBody.get('id'));
    System.assertEquals(500, res.statusCode);
  }

  @isTest static void testContactDeletePass() {
    //Create contact
    Contact contact = new Contact(
      FirstName = 'John',
      LastName = 'Doe',
      Email = 'john@doe.com',
      Activated__c = true
    );
    insert contact;

    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
    
    req.requestURI = REQUEST_URI + contact.Id;
    req.requestBody = Blob.valueOf('');
    req.httpMethod = 'DELETE';
 
    RestContext.request = req;
    RestContext.response= res;
    
    Test.startTest();
    ContactRest.deleteContact();
    Test.stopTest();

    Contact contactDeleted = [SELECT Id, FirstName, LastName, Email, Activated__c FROM Contact WHERE Id = :contact.Id];
    System.assertNotEquals(null, contactDeleted);
    System.assertEquals(false, contactDeleted.Activated__c);
    Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(res.responseBody.toString());
    System.equals(true, responseBody.isEmpty());
    System.assertEquals(204, res.statusCode);
  }

  @isTest static void testContactDeleteFail() {
    //Create contact
    Contact contact = new Contact(
      FirstName = 'John',
      LastName = 'Doe',
      Email = 'john@doe.com',
      Activated__c = true
    );
    insert contact;

    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
    
    req.requestURI = REQUEST_URI + 'AABC12';
    req.requestBody = Blob.valueOf('');
    req.httpMethod = 'DELETE';
 
    RestContext.request = req;
    RestContext.response= res;
    
    Test.startTest();
    ContactRest.deleteContact();
    Test.stopTest();

    Contact contactDeleted = [SELECT Id, FirstName, LastName, Email, Activated__c FROM Contact WHERE Id = :contact.Id];
    System.assertNotEquals(null, contactDeleted);
    System.assertEquals(true, contactDeleted.Activated__c);
    Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(res.responseBody.toString());
    System.assertEquals(false, (Boolean)responseBody.get('success'));
    System.assertEquals(null, (String)responseBody.get('id'));
    System.assertEquals(500, res.statusCode);
  }
}