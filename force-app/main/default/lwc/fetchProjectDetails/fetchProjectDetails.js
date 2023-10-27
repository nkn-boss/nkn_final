import {track,api, LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import candidateDetailsUpload from '@salesforce/apex/GITRestCalloutsMain.candidateDetailsUpload';
import uploadFile from '@salesforce/apex/GITRestCalloutsMain.uploadFile';
export default class fetchProjectDetails extends LightningElement {
    @track showProjectDetails = false;
    @track concatenatedString = '';
    @track showSpinner= false;
    @track flag=true;
    @track nameOfFile;

    @track success=true;
    @track showImmediateReview = true;
    @track showScheduleReview = true;
    @track sdate;
    @track handleOnce=false;
    @track handledone=true;
    handleImmediateReview() {
        this.handleOnce=true;
        this.showScheduleReview=false;
        console.log('Your review processing started, u will get notified.');
        const toastEvent = new ShowToastEvent({
            title: 'Review is being processed ',
            message: 'You will be notified onec it is done.',
            variant: 'success'
        });
        this.dispatchEvent(toastEvent);
    }
    handleScheduleReview(event) {
        this.sdate=event.target.value;
        this.handledone=false;
        console.log('date sele',event.target.value);
    }
    clickschedule(event){
        this.handleOnce = true;
        
        this.showImmediateReview=true;
    }
    done(){
        console.log('selected date ');
        this.handledone=true;
        const toastEvent1 = new ShowToastEvent({
            title: `The Review is scheduled on ${this.sdate}`,
            message: 'You will be notified onec it is done.',
            variant: 'success'
        });
        this.dispatchEvent(toastEvent1);
    }

    handleCheckbox(event) {
        this.handlecheck = event.target.checked;
        this.flag=!this.handlecheck;      
    }
    proceed() {
        this.showProjectDetails = true;
    }

    @track projectName;
    @track userName;
    @track email;
    @track clientId;
    @track privateKey;
    error;
    @api recordId;
    @track fileData
    openfileUpload(event) {
        const file = event.target.files[0]
        var reader = new FileReader()
        reader.onload = () => {
            var base64 = reader.result.split(',')[1]
            this.fileData = {
                'filename': file.name,
                'base64': base64,
                'recordId': this.recordId
            }
            console.log(this.fileData)
        }
        reader.readAsDataURL(file)
        
    }
    updateConcatenatedString(nameOfFile) {
            const parts = nameOfFile.split('.');
            const fileNameWithoutExt = parts[0];
            const fileExt = parts[1];
            this.concatenatedString = fileNameWithoutExt + '_' + this.projectName + '.' + fileExt;   
            console.log('concatenatedStringthis'+this.concatenatedString);
    }
    
    handleClick(){
       this.showSpinner= true;
       this.success=false;
       this.updateConcatenatedString(this.fileData.filename);
       console.log('concatenatedStringthis'+this.concatenatedString);
      //  const {base64, filename, recordId} = this.fileData
        
        uploadFile({ base64:this.fileData.base64, filename:this.concatenatedString})
        .then(result => {
            console.log('Data :'+ result);
            this.privateKey= result;
            this.handleMove();
            this.fileData=null;
        }) .catch(error => {
            console.log(error);
            this.error = error;
            this.showSpinner= false;
        }); 
        
           // this.fileData=null;
    }
    fetchProjectName(event){
        this.projectName = event.target.value;
    }
    fetchEmail(event){
        this.email = event.target.value;
    }
    fetchUserName(event){
        this.userName = event.target.value;
    }
    fetchClientId(event){
        this.clientId = event.target.value;
    }
    get handleDisable(){
        return !(this.projectName && this.email && this.clientId  &&this.userName);   
    }
    handleMove(){
    console.log('Data in handle move :');
     var wrapperData={
        projectName: this.projectName,
        orgEmail:this.email,
        orgUsername:this.userName,
        privateKeyFileId:this.privateKey,
        orgclientId:this.clientId,  
     };
     console.log('Data1 in hm :'+ JSON.stringify(wrapperData));
     candidateDetailsUpload({cd:JSON.stringify(wrapperData)})   
        .then(result => {
            console.log('Data1 :'+ JSON.stringify(wrapperData));
            let titleText = ` Uploaded successfully!!`;
            this.toast(titleText);
            this.handleReset();
            this.showSpinner= false;
        }) .catch(error => {
            console.log(error);
            this.error = error;
            this.showSpinner= false;
        }); 
       

    }
    toast(titleText){
        const evt = new ShowToastEvent({
            title:`${titleText}`, 
            message:'Project Created  Successfully!!!',
            variant:'success',
        });
        this.dispatchEvent(evt);
    }
    handleReset(){
        this.template.querySelectorAll('lightning-input').forEach(element => {
              element.value = null;
            
    });
}
    
    
}