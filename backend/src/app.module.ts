import { Module } from "@nestjs/common"
import { ConfigModule, ConfigService } from "@nestjs/config"
import { TypeOrmModule } from "@nestjs/typeorm"
import { ScheduleModule } from "@nestjs/schedule"

// Módulos da aplicação
import { AuthModule } from "./modules/auth/auth.module"
import { TenantsModule } from "./modules/tenants/tenants.module"
import { UsersModule } from "./modules/users/users.module"
import { ExtensionsModule } from "./modules/extensions/extensions.module"
import { TrunksModule } from "./modules/trunks/trunks.module"
import { QueuesModule } from "./modules/queues/queues.module"
import { GroupsModule } from "./modules/groups/groups.module"
import { IvrModule } from "./modules/ivr/ivr.module"
import { RoutesModule } from "./modules/routes/routes.module"
import { CdrModule } from "./modules/cdr/cdr.module"
import { RecordingsModule } from "./modules/recordings/recordings.module"
import { DashboardModule } from "./modules/dashboard/dashboard.module"
import { AsteriskModule } from "./modules/asterisk/asterisk.module"

@Module({
  imports: [
    // Configuração global
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: ".env",
    }),

    // TypeORM - Banco de dados
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      useFactory: (configService: ConfigService) => ({
        type: "postgres",
        host: configService.get("DB_HOST", "localhost"),
        port: configService.get("DB_PORT", 5432),
        username: configService.get("DB_USER", "pbx_user"),
        password: configService.get("DB_PASSWORD", "pbx_password"),
        database: configService.get("DB_NAME", "pbx_moderno"),
        entities: [__dirname + "/**/*.entity{.ts,.js}"],
        synchronize: configService.get("NODE_ENV") === "development",
        logging: configService.get("DB_LOGGING", false),
      }),
      inject: [ConfigService],
    }),

    // Agendamento de tarefas
    ScheduleModule.forRoot(),

    // Módulos da aplicação
    AuthModule,
    TenantsModule,
    UsersModule,
    ExtensionsModule,
    TrunksModule,
    QueuesModule,
    GroupsModule,
    IvrModule,
    RoutesModule,
    CdrModule,
    RecordingsModule,
    DashboardModule,
    AsteriskModule,
  ],
})
export class AppModule {}
