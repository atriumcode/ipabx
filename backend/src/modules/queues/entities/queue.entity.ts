import { Entity, Column, ManyToOne, JoinColumn, OneToMany } from "typeorm"
import { BaseEntity } from "../../../common/entities/base.entity"
import { Tenant } from "../../tenants/entities/tenant.entity"
import { QueueMember } from "./queue-member.entity"

@Entity("queues")
export class Queue extends BaseEntity {
  @Column({ name: "tenant_id" })
  tenantId: number

  @ManyToOne(() => Tenant)
  @JoinColumn({ name: "tenant_id" })
  tenant: Tenant

  @Column({ length: 255 })
  nome: string

  @Column({ length: 50 })
  numero: string

  @Column({ length: 50, default: "ringall" })
  estrategia: "ringall" | "leastrecent" | "fewestcalls" | "random" | "rrmemory" | "linear"

  @Column({ default: 15 })
  timeout: number

  @Column({ default: 5 })
  retry: number

  @Column({ default: 15 })
  wrapuptime: number

  @Column({ default: 0 })
  maxlen: number

  @Column({ length: 255, nullable: true })
  announce: string

  @Column({ length: 100, default: "from-internal" })
  context: string

  @Column({ length: 100, default: "default" })
  musiconhold: string

  @Column({ default: true })
  ativo: boolean

  @Column({ type: "jsonb", default: {} })
  configuracoes: Record<string, any>

  @OneToMany(
    () => QueueMember,
    (member) => member.queue,
  )
  membros: QueueMember[]
}
