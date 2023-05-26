@isTest
public class ContactService_Test {
  @isTest static void testGetIdByEmail() {
    //Create contact
    Contact contact = new Contact(
      FirstName = 'John',
      LastName = 'Doe',
      Email='john@doe.com'
    );
    insert contact;
    
    // Search contact by right email
    Id contactId = ContactService.getIdByEmail('john@doe.com');
    System.assertEquals(contact.Id, contactId);

    // Search contact by wrong email
    contactId = ContactService.getIdByEmail('robert@doe.com');
    System.assertEquals(null, contactId);
  }
}