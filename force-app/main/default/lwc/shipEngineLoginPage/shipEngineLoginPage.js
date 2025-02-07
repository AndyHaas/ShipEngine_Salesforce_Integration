import { LightningElement } from 'lwc';
import saveApiKey from '@salesforce/apex/mc_SaveAPIKey.saveApiKey'
export default class ShipEngineLoginPage extends LightningElement {
    apiKey = '';

    handleClick(){
       // window.location.replace("https://dashboard.shipengine.com/");
        window.open("https://dashboard.shipengine.com/", '_blank').focus();
    }

    handleChange(event){
        this.apiKey = event.currentTarget.value;        
    }

    saveAPIKey(){
        saveApiKey({apiKey:this.apiKey})
        this.template.querySelector('lightning-input').value = null;
         console.log(`this.apiKey: ${this.apiKey}`);
    }
}