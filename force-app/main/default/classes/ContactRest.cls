/**
 * Class Rest API for Contact Object
 * 
 * @author Nicolas Padiou
 */
@RestResource(urlMapping='/Contact/*')
global with sharing class ContactRest {
  static final String OBJECT_TYPE = 'Contact';

  /**
   * Insert contact if not exist else return contact id
   * 
   * Method : POST
   * 
   * Return body : contact id
   * Return code : 200 (if exist) / 201 (if created)
   */
  @HttpPost
  global static void insertContact() {
    RestManager restManager = new RestManager(RestContext.request, RestContext.response, OBJECT_TYPE);

    try {
      Contact contact = (Contact)restManager.getObject();

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

  /**
   * Update contact
   * 
   * Method : PATCH
   * 
   * Return body : contact id
   * Return code : 200
   */
  @HttpPatch
  global static void updateContact() {
    RestManager restManager = new RestManager(RestContext.request, RestContext.response, OBJECT_TYPE);

    try {
      String contactId = restManager.getId();
      List<Contact> contacts = [SELECT Id FROM Contact WHERE Id = :contactId];
      if (contacts.size() == 1) {
        Contact contact = (Contact)restManager.getObject();
        contact.Id = contactId;
        update contact;
        restManager.response(contact.Id, 200);
      } else {
        throw new RestException('Invalid Id, contact not found.');
      }
    } catch(Exception e) {
      restManager.responseWithErrors(e);
    }
  }

  /**
   * Disable contact
   * 
   * Method : DELETE
   * 
   * Return body : null
   * Return code : 204
   */
  @HttpDelete
  global static void deleteContact() {
    RestManager restManager = new RestManager(RestContext.request, RestContext.response, OBJECT_TYPE);

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