/**
 * Class to manage Request and Response API
 * 
 * @author Nicolas Padiou
 */
public class RestManager {
  private RestRequest request;

  private RestResponse response;

  private String requestBody;

  private String objectType;

  /**
   * Constructor
   * 
   * @param request : the request of the client
   * @param response : the response send to client
   * @param objectType : the type of object to manage (Contact, Contract, ...)
   */
  public RestManager(RestRequest request, RestResponse response, String objectType) {
    this.request = request;
    this.response = response;
    this.requestBody = request.requestBody.toString();
    this.objectType = objectType;
  }

  /**
   * Return the id in the url
   * 
   * @return id
   */
  public String getId() {
    return request.requestURI.substring(this.request.requestURI.lastIndexOf('/')+1);
  }

  /**
   * Deserialize the body request and return the object
   * 
   * @return object with data
   */
  public Object getObject() {
    Type customType = Type.forName(this.objectType);
    return JSON.deserialize(this.requestBody, customType);
  }

  /**
   * Construct the response with success
   */
  public void response(ID id, Integer statusCode) {
    ObjResponse objResponse = new ObjResponse();
    objResponse.id = id;
    objResponse.success = true;
    objResponse.errors = new List<ObjResponseError>();
    this.response.responseBody = Blob.valueOf(JSON.serializePretty(objResponse));
    this.response.statusCode = statusCode;
  }

  /**
   * Construct the response with errors
   */
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

  /**
   * Definition of response object
   */
  public class ObjResponse {
    public String id{get; set;}
    public Boolean success{get; set;}
    public List<ObjResponseError> errors{get; set;}
  }

  /**
   * Definition of error response object
   */
  public class ObjResponseError {
    public String statusCode{get; set;}
    public String message{get; set;}
    public List<String> fields{get; set;}
  }
}