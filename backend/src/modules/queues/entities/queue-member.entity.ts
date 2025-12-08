import { Entity, Column, ManyToOne, JoinColumn, CreateDateColumn, PrimaryGeneratedColumn } from "typeorm"
import { Tenant } from "../../tenants/entities/tenant.entity"
import { Queue } from "./queue.entity"
import { Extension } from "../../extensions/entities/extension.entity"

@Entity("queue_members")
export class QueueMember {
  @PrimaryGeneratedColumn()
  id: number

  @Column({ name: "tenant_id" })
  tenantId: number

  @ManyToOne(() => Tenant)
  @JoinColumn({ name: "tenant_id" })
  tenant: Tenant

  @Column({ name: "queue_id" })
  queueId: number

  @ManyToOne(
    () => Queue,
    (queue) => queue.membros,
  )
  @JoinColumn({ name: "queue_id" })
  queue: Queue

  @Column({ name: "extension_id" })
  extensionId: number

  @ManyToOne(() => Extension)
  @JoinColumn({ name: "extension_id" })
  extension: Extension

  @Column({ length: 255 })
  interface: string

  @Column({ default: 0 })
  penalty: number

  @Column({ default: false })
  paused: boolean

  @CreateDateColumn({ name: "data_criacao" })
  dataCriacao: Date
}
