import { Inject, Injectable } from '@nestjs/common';
import { Connection } from 'amqplib';
import { AMQP_CONNECTION } from 'src/queue/constants';
import { PurchaseTokenDto } from './dto';

@Injectable()
export class PurchaseService {
  constructor(@Inject(AMQP_CONNECTION) private connection: Connection) {}

  async process(params: PurchaseTokenDto) {
    const channel = await this.connection.createChannel();
    channel.publish('exchange1', 'token_purchase', Buffer.from(JSON.stringify({ to: params.publicKey, amount: params.tokens, correlation_id: params.correlationId })));
  }
}
