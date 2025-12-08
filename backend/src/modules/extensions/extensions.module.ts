import { Module } from "@nestjs/common"
import { TypeOrmModule } from "@nestjs/typeorm"
import { ExtensionsService } from "./extensions.service"
import { ExtensionsController } from "./extensions.controller"
import { Extension } from "./entities/extension.entity"

@Module({
  imports: [TypeOrmModule.forFeature([Extension])],
  controllers: [ExtensionsController],
  providers: [ExtensionsService],
  exports: [ExtensionsService],
})
export class ExtensionsModule {}
