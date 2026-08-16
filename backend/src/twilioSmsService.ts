import twilio from "twilio";
import type { AppConfig } from "./config.js";

export type SmsService = {
  sendNumber(recipient: string, value: string): Promise<void>;
};

export function createTwilioSmsService(config: AppConfig): SmsService {
  const client = twilio(config.twilioAccountSid, config.twilioAuthToken);

  return {
    async sendNumber(recipient: string, value: string): Promise<void> {
      await client.messages.create({
        from: config.twilioPhoneNumber,
        to: recipient,
        body: value
      });
    }
  };
}
