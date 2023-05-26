@RestResource(urlMapping='/Contact/*')
global with sharing class ContactRest {
  @HttpPost
  global static void insertContact() {
    RestManager restManager = new RestManager(RestContext.request, RestContext.response, 'Contact');

    Contact contact = new Contact();

    try {
      restManager.populateFields(contact);
      
      Id contactId = ContactService.getIdByEmail(contact.Email);
      if (contactId == null) {
        insert contact;
        restManager.response(contact.id, 201);
      } else {
        restManager.response(contactId, 200);
      }
    } catch (Exception e) {
      restManager.responseWithErrors(e);
    }
  }

  @HttpPatch
  global static void updateContact() {
    RestManager restManager = new RestManager(RestContext.request, RestContext.response, 'Contact');

    try {
      String contactId = restManager.getId();
      List<Contact> contacts = [SELECT Id FROM Contact WHERE Id = :contactId];
      if (contacts.size() == 1) {
        Contact contact = contacts[0];
        restManager.populateFields(contact);
        update contact;
        restManager.response(contact.Id, 200);
      } else {
        throw new RestException('Invalid Id, contact not found.');
      }
    } catch(Exception e) {
      restManager.responseWithErrors(e);
    }
  }

  @HttpDelete
  global static void deleteContact() {
    RestManager restManager = new RestManager(RestContext.request, RestContext.response, 'Contact');

    try {
      String contactId = restManager.getId();

      List<Contact> contacts = [SELECT Id FROM Contact WHERE Id = :contactId];
      if (contacts.size() == 1) {
        Contact contact = contacts[0];
        contact.Activated__c = false;
        update contact;
        restManager.response(null, 204);
      } else {
        throw new RestException('Invalid Id, contact not found.');
      }
    } catch(Exception e) {
      restManager.responseWithErrors(e);
    }
  }
}