import { Module } from '@nestjs/common';
import { TokensController } from './tokens.controller';
import { PurchaseTokenService } from './purchase-token.service';
import { ClientProxyFactory, Transport } from '@nestjs/microservices';
import { RabbitMQModule } from '@golevelup/nestjs-rabbitmq';

@Module({
  imports: [
    RabbitMQModule.forRoot(RabbitMQModule, {
      uri: 'amqp://guest:guest@localhost:5672',
    }),
    AppModule,
  ],
  controllers: [TokensController],
  providers: [
    PurchaseTokenService,
  ],
})
export class AppModule {}
