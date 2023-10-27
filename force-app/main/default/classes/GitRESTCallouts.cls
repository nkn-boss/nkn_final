public with sharing class GitRESTCallouts {
    
    private static final String GITHUB_TOKEN = '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';
    private static final String REPO_OWNER = 'nkn-boss';
    private static final String REPO_NAME = 'mynewrepnkn25';
    private static final String PACKAGE_XML_ID = '0682w00000R6QrOAAV';

    public class CandidateDetails {

        @AuraEnabled
        public String projectName { get; set; }
        @AuraEnabled
        public String orgEmail { get; set; }
        @AuraEnabled
        public String orgUsername { get; set; }
        @AuraEnabled
        public String orgclientId { get; set; }
        @AuraEnabled
        public Id privateKeyFileId { get; set; }
    }

    @AuraEnabled(cacheable = true)
    public static void candidateDetailsUpload(String cd){
        try {
            CandidateDetails cdwrapper=(CandidateDetails)JSON.deserialize(cd,CandidateDetails.class);
            system.debug('wrapper :' + cdwrapper);
            System.debug('projectName-->'+ cdwrapper.projectName);
            System.debug('orgEmail-->'+cdwrapper.orgEmail);
            System.debug('orgUsername-->'+cdwrapper.orgUsername);
            System.debug('orgclientId-->'+cdwrapper.orgclientId);
            System.debug('projectName-->'+cdwrapper.privateKeyFileId);
            //Create Project Record
            

            //Create Repo
            //createGitRepo(cd.projectName,cd.orgUsername,cd.orgclientId);


        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Id uploadFile(String base64, String filename) {
          ContentVersion cv = createContentVersion(base64, filename);

          if (cv == null ) { return null; }
          system.debug('Id'+cv.Id);
           return [SELECT  ContentDocumentId from ContentVersion  where  id=:cv.Id LIMIT 1][0].ContentDocumentId;
          
    }   

    private static ContentVersion createContentVersion(String base64, String filename) {
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(base64);
        cv.Title = filename;
        cv.PathOnClient = filename;
        try {
          insert cv;
          return cv;
        } catch(DMLException e) {
          System.debug(e);
          return null;
        }
      }

    public static String convertPrivateKeyFile(){
        // First, retrieve the file contents as a Blob
        ContentVersion cv = [SELECT VersionData FROM ContentVersion WHERE ContentDocumentId = '0692w00000Pg3lkAAB'];
        Blob fileContents = cv.VersionData;

        // Then, convert the Blob to a base64-encoded string using EncodingUtil
        String base64String = EncodingUtil.base64Encode(fileContents);
        System.debug('--> '+base64String);

        return base64String;
    }

    public static String encryptSecret(String key,String value){

        Blob publicKeyBlob = EncodingUtil.base64Decode(key);
        Blob secretValueBlob = Blob.valueOf(value);

        // Generate a random initialization vector (IV)
        Blob iv = Crypto.generateAesKey(128);

        // Encrypt the secret value using AES encryption
        Blob encryptedValueBlob = Crypto.encrypt('AES256', publicKeyBlob, iv, secretValueBlob);

        // Encode the encrypted value as Base64 strings
        String encryptedValueBase64 = EncodingUtil.base64Encode(encryptedValueBlob);

        // Concatenate the IV and encrypted value into a single string
        String ivAndEncryptedValue = encryptedValueBase64;

        return ivAndEncryptedValue;
        //return encrypted;
    }

    public static void createGitRepo(String repoName,String orgUserName,String orgclientId){
        
        // Authenticate with the GitHub API
        Http h = new Http();
        HttpRequest repoRequest = new HttpRequest();
        repoRequest.setEndpoint('https://api.github.com/user/repos');
        repoRequest.setHeader('Authorization', 'Token ' + GITHUB_TOKEN);
        repoRequest.setHeader('Content-Type', 'application/vnd.github+json');
        repoRequest.setMethod('POST');

        // Set the repository name and other properties
        String jsonBody = '{"name":"' + repoName + '","auto_init":"true"}';
        repoRequest.setBody(jsonBody);

        // Send the request to create the repository
        HttpResponse repoResponse = h.send(repoRequest);

        if (repoResponse.getStatusCode() == 201) {
            // Repository created successfully
            // //Creating Secrets
            // getRepoPublicKey_Test(repoName,'SF_USERNAME',orgUserName);
            // getRepoPublicKey_Test(repoName,'SF_CLIENT_ID',orgclientId);
            // //ContentVersion cv = [SELECT VersionData FROM ContentVersion WHERE ContentDocumentId = '0692w00000Pg3lkAAB'];
            // //getRepoPublicKey_Test(repoName,'SF_PRIVATE_KEY',cv.VersionData);
             String str = 'LS0tLS1CRUdJTiBQUklWQVRFIEtFWS0tLS0tDQpNSUlFdmdJQkFEQU5CZ2txaGtpRzl3MEJBUUVGQUFTQ0JLZ3dnZ1NrQWdFQUFvSUJBUURnOFlxU2RRM00rUkV3DQovMVF4czk3amhiU3hWVGRlL2ltZnYxSkFCQmxyMklLN1gwbisxaml1MXhBdDdGY0FxenRybGp5cml1MkN3dHlUDQp6UFFoaURxREFXK2ptcEdHMUtqY0tYR0JlREFncHhGaXhTUys4ZHBsRXFWR2hmcE0vaExaZVo5SzZqOGtIV0Y2DQo2bERGc0hhM0prSnBCZUNnR0hieERLaUE4Uk9ES2ZJbS9oajV6WWV6U2ljUnZ5TzRLeWQ2bytmZ045dm1xUVdPDQprakRUQjRzZmFMR0hOVHhBQnVJZUJWSkgwQVlEU1BlM2dpbURMbFgxNHVkMkpaK0dvczRUeHNjeVU5dzQ5a0IwDQpMc1pGSGFNUHBVSy9NdkorMGh6elFQTitYVlNKVUxMVWgzM2VUYmtxN2kvaCtFRXJNenZ1L2NzM0QyczZUS3RqDQpPbDBEbGR2bEFnTUJBQUVDZ2dFQU1kU1FNLzJHUHgvMXRQcjY5Yis0NG9JZUV5S2pqNEdTU3ZjaEMxbGRJRXpvDQpPUVhVNklVZ0xXc3JCR0ZVckt0Q0VJVkpqMTdKV3F3OEhPbk1NeGx3ak5EbW9FRi9kM1RvcTB6cS9obFg0QVBpDQprQlRJSFJ5S210VlVrNWplWit2bzFSQmlQMEJCR0lrQnJTNzNFYlFUdUdMYlYxU2IvQnN2VGhyVndTcW1mZW1FDQpqUWYyNThneDhxMVA5ekdHeXBqUE9OOUhWS3QxSEdoWW5QbnpkQzRhNXROWEJVelcwQWVQRVI0QlRTeG1aeXZqDQpycWdPUENxTmxUQWlUTWVMelhPQVREQURJay9RWHpCcFRNTm14S2tZODJ0KzN5WDc2S3NJMEZNNkk3ZmFweC9PDQpBZUt4SUpUTWVEMThRendkeUlLa3lHNlQyeXpsZjRBeHpCTHp5RjNZU1FLQmdRRHpISmlueU9DTDRORTFXV0JODQozNlNoQmJndUZ5UjZ0MThJcGhkbk42OHl2MUFBcUlQSjk1YU1Mb29tVWFPYTVPcmpMM1dHL0E0NDkyRzJIZ1NmDQprWVVMYitjLzRNVmt1Tjh4N2J0cHlsUi9nTEdDM3pGZFArUklKWVZkbVlsdkNGVVc3QWE4cWlGSHdSUmswcWlzDQpvSzNzU1pub1VCZEhUYXFmYlZqWVczOUUwd0tCZ1FEczNsL2ZCQU1RdUVoTTRCYnRWTWJSd2FicXhZai9XNDdoDQplNUVJZkJ0UW9yWHlmVndpZFp2VjFkdlVldEQ2elZya0l0YkVZVHc1b3ByZ053MDBmTEYyQy9CMzc4Zm5hekxODQppeUR6bUlTTllsNEpyVFVOdEhTeklxZG5wSWx4Tm5UZTY0OE9HUVVJSDl5L0tZcmhja2o3aEM0cmwwbnlaekNTDQpRRFdxcjV0Slp3S0JnUURZOUs0dkhnOTJCVDN1dEVKRGZOQTRleGd3MmFwT2NaSzM3ekYzaGJRdVA1a3YzVE12DQpiR3JIMDBpcWhiVFJxSFVPSmU1bWRrNWkvRElSQ3B6cG9qM3ZSUUJFZTF6dFZDYXJNaE5NaDZuODEyYVMrb2ZkDQpSZ1Y5ZFM2ZHAwV0U5eFNvamg0OUJEOEsvLzRwTSs0ZmtJMW1EeER3eDNqZXd5ci9kK0FQeFNmQXpRS0JnR1FWDQpOYmI2Yi8waGtGTURJRXpaVkVTT3FXTnJZWTViOWt3cHRNYzhBU0thRFh6UElSM2lTWjBaaHBBSjhNRDRBZDZCDQpKZlBHRGZkZ1VFWktuSWEvNVErMnpiMHZrR3lrcTh1VGJMSGdrS2xZbGRsSzJTN1lQN0x0QW9UVlRjbUxNK2g0DQo2WElRZWtMTGk2OHQ4Mk44c1grc2d3R2lJL21MUmtlVlg5ZWw2VndqQW9HQkFNVktCSkJNc1FDMnQ1Z0k1ZTl6DQpRSHBmcGFGNWljMnVGeVdzVmd6THpEOFZOZmtDQUJRU2psSys2UjhXb3ZTMzdDN1Rma2NBMHBoMUgwSW40SjdHDQpuaEgwaTlRVjRqV2xVdVhmZ2FoaDZHVkM5VStJWGlxdDFBZXZ5US8rY1BnMGxzb2JaY3ZQT3lva05BSVFrUHlCDQo2dENoL3hQR2dWMFl1M3hZdlhBbGpJL0UNCi0tLS0tRU5EIFBSSVZBVEUgS0VZLS0tLS0NCg==';
            // getRepoPublicKey_Test(repoName,'SF_PRIVATE_KEY',str);

            //Get the Private key file data put in the Private key below
            //getRepoPublicKey(repoName,'SF_PRIVATE_KEY',-----);
            uploadVariables(repoName,'SF_USERNAME',orgUserName);
            uploadVariables(repoName,'SF_CLIENT_ID',orgclientId);
            uploadVariables(repoName,'SF_PRIVATE_KEY',str);

            //Pushing the Package.xml
            createBlob(repoName);
        }else{
            // Handle error creating repository
            System.debug('ERROR Repo !!!'+repoResponse.getStatusCode()+'--Error Messsage--'+repoResponse.getBody());
        }
    }

    public static void uploadVariables(String repoName,String secretName,String secretValue){
        // create a new Http request
        HttpRequest secretRequest = new HttpRequest();
        secretRequest.setEndpoint('https://api.github.com/repos/nkn-boss/' + repoName + '/actions/variables/');
        secretRequest.setMethod('POST');
        secretRequest.setHeader('Content-Type', 'application/vnd.github+json');
        secretRequest.setHeader('Authorization', 'Bearer ' + GITHUB_TOKEN);

        // set the request body with the Varibles value
        String requestBody = '{"name": "' + secretName + '","value":"'+ secretValue +'"}';
        secretRequest.setBody(requestBody);

        // send the request and get the response
        Http http = new Http();
        HttpResponse secretResponse = http.send(secretRequest);

        // handle the response to check if the Varibles was created successfully
        if (secretResponse.getStatusCode() == 201) {
            System.debug('Repository Varibles created successfully');
        } else {
            System.debug('Error creating repository Varibles: ' + secretResponse.getBody());
        }
    }

    public static void createBlob(String repoName){
        
        //Creating Blob
        Http h = new Http();
        HttpRequest blobRequest = new HttpRequest();

        ContentVersion packageXml = [SELECT Id,PathOnClient, VersionData FROM ContentVersion WHERE Id = :PACKAGE_XML_ID WITH SECURITY_ENFORCED ];
        String b = EncodingUtil.base64Encode(packageXml.VersionData);

        blobRequest.setEndpoint('https://api.github.com/repos/nkn-boss/'+ repoName + '/git/blobs');
        blobRequest.setHeader('Authorization', 'Token ' + GITHUB_TOKEN);
        blobRequest.setHeader('Content-Type', 'application/vnd.github+json');
        blobRequest.setMethod('POST');

        String jsonBody = '{"content":"'+b+'","encoding":"base64"}';
        blobRequest.setBody(jsonBody);

        HttpResponse blobResponse = h.send(blobRequest);

        if (blobResponse.getStatusCode() == 201) {
            // Blob created successfully
            BlobResponseWrapper obj = (BlobResponseWrapper)System.JSON.deserialize(blobResponse.getBody(), BlobResponseWrapper.class);
            createTree(repoName,obj.sha);
        }else{
            // Handle error creating repository
            System.debug('ERROR Blob !!!'+blobResponse.getStatusCode()+'--Error Messsage--');
        }
    }

    public static void createTree(String repoName, String blobSHA){

        //Creating Tree
        Http h = new Http();
        HttpRequest treeRequest = new HttpRequest();

        treeRequest.setEndpoint('https://api.github.com/repos/nkn-boss/'+ repoName + '/git/trees');
        treeRequest.setHeader('Authorization', 'Token ' + GITHUB_TOKEN);
        treeRequest.setHeader('Content-Type', 'application/vnd.github+json');
        String jsonBody = '{"tree":[{"path":"package.xml","mode":"100644","sha":"'+blobSHA+'"}]}';
        treeRequest.setBody(jsonBody);
        treeRequest.setMethod('POST');

        HttpResponse treeReponse = h.send(treeRequest);

        if (treeReponse.getStatusCode() == 201) {
            // Repository created successfully
            TreeResponseWrapper obj = (TreeResponseWrapper)System.JSON.deserialize(treeReponse.getBody(), TreeResponseWrapper.class);
            createCommit(repoName,obj.sha);
        }else{
            // Handle error creating repository
            System.debug('ERROR Repo !!!'+treeReponse.getStatusCode()+'--Error Messsage--');
        }
    }

    public static void createCommit(String repoName,String treeSHA){
       
        //Creating Commit
        Http h = new Http();
        HttpRequest commitRequest = new HttpRequest();

        commitRequest.setEndpoint('https://api.github.com/repos/nkn-boss/'+ repoName + '/git/commits');
        commitRequest.setHeader('Authorization', 'Token ' + GITHUB_TOKEN);
        commitRequest.setHeader('Content-Type', 'application/vnd.github+json');
        String jsonBody = '{"message":"My API Commit","tree":"'+treeSHA+'"}';
        commitRequest.setBody(jsonBody);
        commitRequest.setMethod('POST');

        HttpResponse commitResponse = h.send(commitRequest);

        if (commitResponse.getStatusCode() == 201) {
            // Repository created successfully
            CommitResponseWrapper obj = (CommitResponseWrapper)System.JSON.deserialize(commitResponse.getBody(), CommitResponseWrapper.class);
            updateReference(repoName,obj.sha);
        }else{
            // Handle error creating repository
            System.debug('ERROR Repo !!!'+commitResponse.getStatusCode()+'--Error Messsage--');
        }
    }

    public static void updateReference(String repoName,String commitSHA){
        
        //Update the ref for the head with new sha
        Http h = new Http();
        HttpRequest updateRefeRequest = new HttpRequest();

        updateRefeRequest.setEndpoint('https://api.github.com/repos/nkn-boss/'+ repoName + '/git/refs');
        updateRefeRequest.setHeader('Authorization', 'Token ' + GITHUB_TOKEN);
        updateRefeRequest.setHeader('Content-Type', 'application/vnd.github+json');
        updateRefeRequest.setMethod('POST');

        //jsonBody = '{"sha":"'+obj2.sha+'","force":"true"}';
        String jsonBody = '{"sha":"'+commitSHA+'","ref":"refs/heads/master"}';
        updateRefeRequest.setBody(jsonBody);

        HttpResponse updateRefResponse = h.send(updateRefeRequest);

        if(updateRefResponse.getStatusCode() == 201){
            System.debug('ref updated !!!!');
            System.debug('Res REfer-->'+updateRefResponse.getBody());
        }else{
            System.debug('Ref not Updated !!!!');
        }
    }

    public static void getRepoPublicKey(String repoName,String secretName,String secretValue){
        // create a new Http request
        HttpRequest keyRequest = new HttpRequest();
        keyRequest.setEndpoint('https://api.github.com/repos/nkn-boss/' + repoName + '/actions/secrets/public-key');
        keyRequest.setMethod('GET');
        keyRequest.setHeader('Authorization', 'Bearer ' + GITHUB_TOKEN);
        keyRequest.setHeader('Content-Type', 'application/vnd.github+json');

         // send the request and get the response
         Http http = new Http();
         HttpResponse keyResponse = http.send(keyRequest);
 
         // handle the response to check if the secret was created successfully
        if (keyResponse.getStatusCode() == 200) {
            System.debug('Public Key Fetched successfully');
            PublicKeyResponse obj = (PublicKeyResponse)System.JSON.deserialize(keyResponse.getBody(), PublicKeyResponse.class);
            uploadSecrets(repoName,secretName,secretValue,obj.key_id);
        } else {
            System.debug('Error Retriving Public Key ' + keyResponse.getBody());
        }
    }

    public static void uploadSecrets(String repoName,String secretName,String secretValue,String keyId){
        // create a new Http request
        HttpRequest secretRequest = new HttpRequest();
        secretRequest.setEndpoint('https://api.github.com/repos/nkn-boss/' + repoName + '/actions/secrets/' + secretName);
        secretRequest.setMethod('PUT');
        secretRequest.setHeader('Authorization', 'Bearer ' + GITHUB_TOKEN);

        // set the request body with the secret value
        String requestBody = '{"encrypted_value": "' + EncodingUtil.base64Encode(Blob.valueOf(secretValue)) + '","key_id":"'+ keyId +'"}';
        secretRequest.setBody(requestBody);

        // send the request and get the response
        Http http = new Http();
        HttpResponse secretResponse = http.send(secretRequest);

        // handle the response to check if the secret was created successfully
        if (secretResponse.getStatusCode() == 201) {
            System.debug('Repository secret created successfully');
        } else {
            System.debug('Error creating repository secret: ' + secretResponse.getBody());
        }
    }

    public static void getRepoPublicKey_Test(String repoName,String secretName,String secretValue){
        // create a new Http request
        HttpRequest keyRequest = new HttpRequest();
        keyRequest.setEndpoint('https://api.github.com/repos/nkn-boss/' + repoName + '/actions/secrets/public-key');
        keyRequest.setMethod('GET');
        keyRequest.setHeader('Authorization', 'Bearer ' + GITHUB_TOKEN);
        keyRequest.setHeader('Content-Type', 'application/vnd.github+json');

         // send the request and get the response
         Http http = new Http();
         HttpResponse keyResponse = http.send(keyRequest);
 
         // handle the response to check if the secret was created successfully
        if (keyResponse.getStatusCode() == 200) {
            System.debug('Public Key Fetched successfully');
            PublicKeyResponse obj = (PublicKeyResponse)System.JSON.deserialize(keyResponse.getBody(), PublicKeyResponse.class);
            uploadSecrets_test(repoName,secretName,encryptSecret(obj.key,secretValue),obj.key_id);
        } else {
            System.debug('Error Retriving Public Key ' + keyResponse.getBody());
        }
    }

    public static void uploadSecrets_test(String repoName,String secretName,String secretValue,String keyId){
        // create a new Http request
        HttpRequest secretRequest = new HttpRequest();
        secretRequest.setEndpoint('https://api.github.com/repos/nkn-boss/' + repoName + '/actions/secrets/' + secretName);
        secretRequest.setMethod('PUT');
        secretRequest.setHeader('Authorization', 'Bearer ' + GITHUB_TOKEN);

        // set the request body with the secret value
        String requestBody = '{"encrypted_value": "' + secretValue + '","key_id":"'+ keyId +'"}';
        secretRequest.setBody(requestBody);

        // send the request and get the response
        Http http = new Http();
        HttpResponse secretResponse = http.send(secretRequest);

        // handle the response to check if the secret was created successfully
        if (secretResponse.getStatusCode() == 201) {
            System.debug('Repository secret created successfully');
        } else {
            System.debug('Error creating repository secret: ' + secretResponse.getBody());
        }
    }

    public class BlobResponseWrapper{

        public String url;
        public String sha;
    }
    public class TreeResponseWrapper{
        public String sha;	//cd8274d15fa3ae2ab983129fb037999f264ba9a7
        public String url;	//https://api.github.com/repos/octocat/Hello-World/trees/cd8274d15fa3ae2ab983129fb037999f264ba9a7
        public cls_tree[] tree;
        public boolean truncated;
    }

    public class cls_tree {
        public String path;	//file.rb
        public String mode;	//100644
        public String type;	//blob
        public Integer size;	//132
        public String sha;	//7c258a9869f33c1e1e1f74fbb32f07c86cb5a75b
        public String url;	//https://api.github.com/repos/octocat/Hello-World/git/blobs/7c258a9869f33c1e1e1f74fbb32f07c86cb5a75b
    }

    public class PublicKeyResponse{
        public String key;
        public String key_id;
    }
}