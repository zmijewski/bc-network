import { DynamicModule, Module, Provider } from '@nestjs/common';
import { connect, Connection } from 'amqplib'
import { AMQP_CONNECTION } from './constants';

@Module({})
export class QueueModule {
  static async forRoot(uri: string): Promise<DynamicModule> {
    const connection: Connection = await connect(uri);

    const amqpConnection: Provider = {
      provide: AMQP_CONNECTION,
      useValue: connection
    }

    return {
      module: QueueModule,
      providers: [amqpConnection],
      exports: [amqpConnection],
      global: true
    }
}
}
