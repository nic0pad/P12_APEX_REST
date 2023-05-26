@RestResource(urlMapping='/Contact/*')
global with sharing class ContactRest {
  @HttpPost
  global static void insertContact() {
    RestManager restManager = new RestManager(RestContext.request, RestContext.response, 'Contact');

    Contact contact = new Contact();
    restManager.populateFields(contact);

    try {
      List<Contact> contacts = ContactService.getByEmail(contact.Email);
      if (contacts.isEmpty()) {
        insert contact;
        restManager.response(contact.id);
      } else {
        restManager.response(contacts[0].Id);
      }
    } catch (Exception e) {
      restManager.responseWithErrors(e);
    }
  }

  @HttpPatch
  global static void updateContact() {
    RestManager restManager = new RestManager(RestContext.request, RestContext.response, 'Contact');

    String contactId = restManager.getId();

    try {
      Contact contact = [SELECT Id FROM Contact WHERE Id = :contactId];
      restManager.populateFields(contact);

      update contact;
      restManager.response(contact.Id);
    } catch(Exception e) {
      restManager.responseWithErrors(e);
    }
  }

  @HttpDelete
  global static void deleteContact() {
    RestManager restManager = new RestManager(RestContext.request, RestContext.response, 'Contact');

    try {
      String contactId = restManager.getId();
      Contact contact = [SELECT Id FROM Contact WHERE Id = :contactId];
      contact.Activated__c = false;
      update contact;

      restManager.response(null);
    } catch(Exception e) {
      restManager.responseWithErrors(e);
    }
  }
}