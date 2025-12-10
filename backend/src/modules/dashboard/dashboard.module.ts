import { Module } from "@nestjs/common";

import { DashboardController } from "./dashboard.controller";
import { DashboardService } from "./dashboard.service";

import { ExtensionsModule } from "../extensions/extensions.module";
import { TrunksModule } from "../trunks/trunks.module";
import { QueuesModule } from "../queues/queues.module";
import { CdrModule } from "../cdr/cdr.module";

@Module({
  imports: [
    ExtensionsModule,
    TrunksModule,
    QueuesModule,
    CdrModule,   // <-- ESSENCIAL! OBRIGATÓRIO!
  ],
  controllers: [DashboardController],
  providers: [DashboardService],
})
export class DashboardModule {}
