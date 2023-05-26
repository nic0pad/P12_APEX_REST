public with sharing class ContactService {
  public static List<Contact> getByEmail(String email) {
    return [SELECT Id FROM Contact WHERE Email = :email];
  }
}