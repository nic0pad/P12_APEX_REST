public class RestManager {
  private RestRequest request;

  private RestResponse response;

  private String requestBody;

  private String objectType;

  public RestManager(RestRequest request, RestResponse response, String objectType) {
    this.request = request;
    this.response = response;
    this.requestBody = request.requestBody.toString();
    this.objectType = objectType;
  }

  public Map<String, Object> getParams() {
    return (Map<String, Object>)JSON.deserializeUntyped(this.requestBody);
  }

  public String getId() {
    return request.requestURI.substring(this.request.requestURI.lastIndexOf('/')+1);
  }

  public void populateFields(Sobject obj) {
    Map<String, Object> params = this.getParams();
    for(String fieldName : params.keySet()) {
      if (fieldName != 'attributes') {
        String fieldType = this.getFieldType(fieldName);
        if (fieldType == 'DATE') {
          obj.put(fieldName, Date.parse((String)params.get(fieldName)));
        } else {
          obj.put(fieldName, params.get(fieldName));
        }
      }
    }
  }

  /**
   * Return the type of a field
   */
  private String getFieldType(String fieldName) {
    Map<String, Schema.SObjectField> M;
    if (this.objectType == 'Contract') M = Schema.SObjectType.Contract.fields.getMap();
    if (this.objectType == 'Contact') M = Schema.SObjectType.Contact.fields.getMap();
    Schema.SObjectField field = M.get(fieldName);
    if (field == null) {
      return null;
    }
    Schema.DisplayType fieldType = field.getDescribe().getType();
    return fieldType.name();
  }

  public void response(ID id, Integer statusCode) {
    ObjResponse objResponse = new ObjResponse();
    objResponse.id = id;
    objResponse.success = true;
    objResponse.errors = new List<ObjResponseError>();
    this.response.responseBody = Blob.valueOf(JSON.serializePretty(objResponse));
    this.response.statusCode = statusCode;
  }

  public void responseWithErrors(Exception e) {
    ObjResponse objResponse = new ObjResponse();
    objResponse.success = false;
    objResponse.errors = new List<ObjResponseError>();

    ObjResponseError objError = new ObjResponseError();
    objError.statusCode = e.getTypeName();
    objError.message = e.getMessage();
    objResponse.errors.add(objError);

    if (e.getTypeName() == 'System.DmlException' && e.getNumDml() > 0) {
      for (Integer i = 0; i < e.getNumDml(); i++) {
        objError = new ObjResponseError();
        objError.statusCode = e.getDmlStatusCode(i);
        objError.message = e.getDmlMessage(i);
        objError.fields = e.getDmlFieldNames(i);
        objResponse.errors.add(objError);
      }
    }
    
    this.response.responseBody = Blob.valueOf(JSON.serializePretty(objResponse));
    this.response.statusCode = 500;
  }

  public class ObjResponse {
    public String id{get; set;}
    public Boolean success{get; set;}
    public List<ObjResponseError> errors{get; set;}
  }

  public class ObjResponseError {
    public String statusCode{get; set;}
    public String message{get; set;}
    public List<String> fields{get; set;}
  }
}