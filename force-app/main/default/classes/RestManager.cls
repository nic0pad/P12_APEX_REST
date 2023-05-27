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

  public String getId() {
    return request.requestURI.substring(this.request.requestURI.lastIndexOf('/')+1);
  }

  public Object getObject() {
    Type customType = Type.forName(this.objectType);
    return JSON.deserialize(this.requestBody, customType);
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