import { createElement } from "lwc";
import ShipEngineLoginPage from "c/shipEngineLoginPage";
import saveApiKey from "@salesforce/apex/ShipStationAPIKeyController.saveApiKey";

// Mock the Apex method
jest.mock(
    "@salesforce/apex/ShipStationAPIKeyController.saveApiKey",
    () => {
        return {
            default: jest.fn()
        };
    },
    { virtual: true }
);

describe("c-ship-engine-login-page", () => {
    let element;

    beforeEach(() => {
        // Create the component
        element = createElement("c-ship-engine-login-page", {
            is: ShipEngineLoginPage
        });
        document.body.appendChild(element);
    });

    afterEach(() => {
        // Clean up after each test
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    it("initializes with default values", () => {
        // Verify component was created with expected initial state
        expect(element.testApiKey).toBe("");
    });

    it("updates apiKey when input value changes", () => {
        // Get the input element
        const inputEl = element.shadowRoot.querySelector("lightning-input");

        // Simulate user input
        inputEl.value = "test-api-key";
        inputEl.dispatchEvent(new CustomEvent("change"));

        // Verify apiKey was updated
        expect(element.testApiKey).toBe("test-api-key");
    });

    it("calls saveApiKey method when Add API Key button is clicked", () => {
        // We can't set apiKey directly, so we need to simulate the input instead
        const inputEl = element.shadowRoot.querySelector("lightning-input");
        inputEl.value = "test-api-key";
        inputEl.dispatchEvent(new CustomEvent("change"));

        // Get the button element and click it
        const buttonEl = element.shadowRoot.querySelector(".api-key-btn");
        buttonEl.click();

        // Verify the Apex method was called with the right parameters
        expect(saveApiKey).toHaveBeenCalledWith({ apiKey: "test-api-key" });
    });

    it("clears input field after saving API key", () => {
        // Setup
        const inputEl = element.shadowRoot.querySelector("lightning-input");
        inputEl.value = "test-api-key";

        // Simulate user input and save
        inputEl.dispatchEvent(new CustomEvent("change"));
        const buttonEl = element.shadowRoot.querySelector(".api-key-btn");
        buttonEl.click();

        // Verify input field was cleared
        expect(inputEl.value).toBeNull();
    });

    it("opens ShipEngine dashboard in new tab when Connect ShipEngine button is clicked", () => {
        // Spy on window.open
        const windowOpenSpy = jest.spyOn(window, "open").mockImplementation(() => {
            return { focus: jest.fn() };
        });

        // Get the Connect ShipEngine button and click it
        const connectButton = element.shadowRoot.querySelector(".instruction-container lightning-button");
        connectButton.click();

        // Verify window.open was called with the right URL
        expect(windowOpenSpy).toHaveBeenCalledWith("https://dashboard.shipengine.com/", "_blank");

        // Clean up
        windowOpenSpy.mockRestore();
    });
});
