import { LightningElement, api } from "lwc";
import saveApiKey from "@salesforce/apex/ShipStationAPIKeyController.saveApiKey";
export default class ShipEngineLoginPage extends LightningElement {
    apiKey = "";

    // For testing purposes only
    @api
    get testApiKey() {
        return this.apiKey;
    }

    handleClick() {
        // window.location.replace("https://dashboard.shipengine.com/");
        window.open("https://dashboard.shipengine.com/", "_blank").focus();
    }

    handleChange(event) {
        this.apiKey = event.currentTarget.value;
    }

    saveAPIKey() {
        saveApiKey({ apiKey: this.apiKey });
        this.template.querySelector("lightning-input").value = null;
    }
}
