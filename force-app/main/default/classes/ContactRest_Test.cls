@isTest
public class ContactRest_Test {
  @isTest static void testContactInsertPass() {
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();

    Contact contact = new Contact(
      FirstName = 'John',
      LastName = 'Doe',
      Email='john@doe.com'
    );
    
    req.requestURI = '/services/apexrest/Contact/';
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
  }

  @isTest static void testContactInsertFailed() {
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();

    Contact contact = new Contact(
      FirstName = 'John',
      Email='john@doe.com'
    );
    
    req.requestURI = '/services/apexrest/Contact/';
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
    
    req.requestURI = '/services/apexrest/Contact/';
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
  }
}