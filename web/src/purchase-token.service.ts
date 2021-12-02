import { AmqpConnection } from '@golevelup/nestjs-rabbitmq';
import { Injectable } from '@nestjs/common';
import { PurchaseTokenDto } from './purchase-token.dto';


@Injectable()
export class PurchaseTokenService {
  constructor(private readonly amqpConnection: AmqpConnection) {}

  process(params: PurchaseTokenDto): void {
    this.amqpConnection.publish('exchange1', 'token_purchase', { to: params.publicKey, amount: params.tokens, correlation_id: params.correlationId });
  }
}
