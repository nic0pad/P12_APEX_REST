public with sharing class ContactService {
  public static ID getIdByEmail(String email) {
    List<Contact> contacts =  [SELECT Id FROM Contact WHERE Email = :email];
    if (contacts.size() == 1) {
      return contacts[0].Id;
    }
    return null;
  }
}