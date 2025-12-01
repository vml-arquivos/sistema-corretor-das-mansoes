CREATE TYPE "public"."ai_role" AS ENUM('user', 'assistant', 'system');--> statement-breakpoint
CREATE TYPE "public"."buyer_profile" AS ENUM('investidor', 'primeira_casa', 'upgrade', 'curioso', 'indeciso');--> statement-breakpoint
CREATE TYPE "public"."client_type" AS ENUM('comprador', 'locatario', 'proprietario');--> statement-breakpoint
CREATE TYPE "public"."interaction_type" AS ENUM('ligacao', 'whatsapp', 'email', 'visita', 'reuniao', 'proposta', 'nota', 'status_change');--> statement-breakpoint
CREATE TYPE "public"."interest_type" AS ENUM('venda', 'locacao', 'ambos');--> statement-breakpoint
CREATE TYPE "public"."message_type" AS ENUM('incoming', 'outgoing');--> statement-breakpoint
CREATE TYPE "public"."priority" AS ENUM('baixa', 'media', 'alta', 'urgente');--> statement-breakpoint
CREATE TYPE "public"."property_type" AS ENUM('casa', 'apartamento', 'cobertura', 'terreno', 'comercial', 'rural', 'lancamento');--> statement-breakpoint
CREATE TYPE "public"."qualification" AS ENUM('quente', 'morno', 'frio', 'nao_qualificado');--> statement-breakpoint
CREATE TYPE "public"."role" AS ENUM('user', 'admin');--> statement-breakpoint
CREATE TYPE "public"."source" AS ENUM('site', 'whatsapp', 'instagram', 'facebook', 'indicacao', 'portal_zap', 'portal_vivareal', 'portal_olx', 'google', 'outro');--> statement-breakpoint
CREATE TYPE "public"."stage" AS ENUM('novo', 'contato_inicial', 'qualificado', 'visita_agendada', 'visita_realizada', 'proposta', 'negociacao', 'fechado_ganho', 'fechado_perdido', 'sem_interesse');--> statement-breakpoint
CREATE TYPE "public"."status" AS ENUM('disponivel', 'reservado', 'vendido', 'alugado', 'inativo');--> statement-breakpoint
CREATE TYPE "public"."transaction_type" AS ENUM('venda', 'locacao', 'ambos');--> statement-breakpoint
CREATE TYPE "public"."urgency_level" AS ENUM('baixa', 'media', 'alta', 'urgente');--> statement-breakpoint
CREATE TYPE "public"."webhook_status" AS ENUM('success', 'error', 'pending');--> statement-breakpoint
CREATE TABLE "ai_context_status" (
	"id" serial PRIMARY KEY NOT NULL,
	"sessionId" varchar(255) NOT NULL,
	"phone" varchar(20) NOT NULL,
	"message" text NOT NULL,
	"role" "ai_role" NOT NULL,
	"createdAt" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "analytics_events" (
	"id" serial PRIMARY KEY NOT NULL,
	"eventType" varchar(50) NOT NULL,
	"propertyId" integer,
	"leadId" integer,
	"userId" integer,
	"source" varchar(100),
	"medium" varchar(100),
	"campaign" varchar(255),
	"url" varchar(500),
	"referrer" varchar(500),
	"userAgent" text,
	"ipAddress" varchar(45),
	"metadata" json,
	"createdAt" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "blog_categories" (
	"id" serial PRIMARY KEY NOT NULL,
	"name" varchar(100) NOT NULL,
	"slug" varchar(100) NOT NULL,
	"description" text,
	"createdAt" timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "blog_categories_slug_unique" UNIQUE("slug")
);
--> statement-breakpoint
CREATE TABLE "blog_posts" (
	"id" serial PRIMARY KEY NOT NULL,
	"title" varchar(255) NOT NULL,
	"slug" varchar(255) NOT NULL,
	"excerpt" text,
	"content" text NOT NULL,
	"featuredImage" varchar(500),
	"categoryId" integer,
	"authorId" integer,
	"metaTitle" varchar(255),
	"metaDescription" text,
	"published" boolean DEFAULT false,
	"publishedAt" timestamp,
	"views" integer DEFAULT 0,
	"createdAt" timestamp DEFAULT now() NOT NULL,
	"updatedAt" timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "blog_posts_slug_unique" UNIQUE("slug")
);
--> statement-breakpoint
CREATE TABLE "campaign_sources" (
	"id" serial PRIMARY KEY NOT NULL,
	"name" varchar(255) NOT NULL,
	"source" varchar(100) NOT NULL,
	"medium" varchar(100),
	"campaignId" varchar(255),
	"budget" numeric(10, 2),
	"clicks" integer DEFAULT 0,
	"impressions" integer DEFAULT 0,
	"conversions" integer DEFAULT 0,
	"active" boolean DEFAULT true,
	"startDate" date,
	"endDate" date,
	"notes" text,
	"createdAt" timestamp DEFAULT now() NOT NULL,
	"updatedAt" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "client_interests" (
	"id" serial PRIMARY KEY NOT NULL,
	"clientId" integer NOT NULL,
	"propertyType" varchar(100),
	"interestType" "interest_type",
	"budgetMin" integer,
	"budgetMax" integer,
	"preferredNeighborhoods" text,
	"notes" text,
	"createdAt" timestamp DEFAULT now() NOT NULL,
	"updatedAt" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "commissions" (
	"id" serial PRIMARY KEY NOT NULL,
	"propertyId" integer NOT NULL,
	"leadId" integer NOT NULL,
	"ownerId" integer,
	"salePrice" numeric(12, 2) NOT NULL,
	"commissionRate" numeric(5, 2) NOT NULL,
	"commissionAmount" numeric(12, 2) NOT NULL,
	"splitWithAgent" boolean DEFAULT false,
	"agentName" varchar(255),
	"agentCommissionAmount" numeric(12, 2),
	"status" varchar(50) DEFAULT 'pending',
	"paymentDate" date,
	"notes" text,
	"transactionId" integer,
	"createdAt" timestamp DEFAULT now() NOT NULL,
	"updatedAt" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "interactions" (
	"id" serial PRIMARY KEY NOT NULL,
	"leadId" integer NOT NULL,
	"userId" integer,
	"type" "interaction_type" NOT NULL,
	"subject" varchar(255),
	"description" text,
	"metadata" text,
	"createdAt" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "leads" (
	"id" serial PRIMARY KEY NOT NULL,
	"name" varchar(255) NOT NULL,
	"email" varchar(320),
	"phone" varchar(20),
	"whatsapp" varchar(20),
	"source" "source" DEFAULT 'site',
	"stage" "stage" DEFAULT 'novo' NOT NULL,
	"clientType" "client_type" DEFAULT 'comprador' NOT NULL,
	"qualification" "qualification" DEFAULT 'nao_qualificado' NOT NULL,
	"buyerProfile" "buyer_profile",
	"urgencyLevel" "urgency_level" DEFAULT 'media',
	"interestedPropertyId" integer,
	"transactionInterest" "transaction_type" DEFAULT 'venda',
	"budgetMin" integer,
	"budgetMax" integer,
	"preferredNeighborhoods" text,
	"preferredPropertyTypes" text,
	"notes" text,
	"tags" text,
	"assignedTo" integer,
	"score" integer DEFAULT 0,
	"priority" "priority" DEFAULT 'media',
	"createdAt" timestamp DEFAULT now() NOT NULL,
	"updatedAt" timestamp DEFAULT now() NOT NULL,
	"lastContactedAt" timestamp,
	"convertedAt" timestamp
);
--> statement-breakpoint
CREATE TABLE "message_buffer" (
	"id" serial PRIMARY KEY NOT NULL,
	"phone" varchar(20) NOT NULL,
	"messageId" varchar(255) NOT NULL,
	"content" text,
	"type" "message_type" NOT NULL,
	"timestamp" timestamp DEFAULT now() NOT NULL,
	"processed" integer DEFAULT 0 NOT NULL,
	"createdAt" timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "message_buffer_messageId_unique" UNIQUE("messageId")
);
--> statement-breakpoint
CREATE TABLE "owners" (
	"id" serial PRIMARY KEY NOT NULL,
	"name" varchar(255) NOT NULL,
	"cpfCnpj" varchar(20),
	"email" varchar(320),
	"phone" varchar(20),
	"whatsapp" varchar(20),
	"address" text,
	"city" varchar(100),
	"state" varchar(2),
	"zipCode" varchar(10),
	"bankName" varchar(100),
	"bankAgency" varchar(20),
	"bankAccount" varchar(30),
	"pixKey" varchar(255),
	"notes" text,
	"active" boolean DEFAULT true,
	"createdAt" timestamp DEFAULT now() NOT NULL,
	"updatedAt" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "properties" (
	"id" serial PRIMARY KEY NOT NULL,
	"title" varchar(255) NOT NULL,
	"description" text,
	"referenceCode" varchar(50),
	"propertyType" "property_type" NOT NULL,
	"transactionType" "transaction_type" NOT NULL,
	"address" varchar(255),
	"neighborhood" varchar(100),
	"city" varchar(100),
	"state" varchar(2),
	"zipCode" varchar(10),
	"latitude" varchar(50),
	"longitude" varchar(50),
	"salePrice" integer,
	"rentPrice" integer,
	"condoFee" integer,
	"iptu" integer,
	"bedrooms" integer,
	"bathrooms" integer,
	"suites" integer,
	"parkingSpaces" integer,
	"totalArea" integer,
	"builtArea" integer,
	"features" text,
	"images" text,
	"mainImage" varchar(500),
	"status" "status" DEFAULT 'disponivel' NOT NULL,
	"featured" boolean DEFAULT false,
	"published" boolean DEFAULT true,
	"metaTitle" varchar(255),
	"metaDescription" text,
	"slug" varchar(255),
	"createdAt" timestamp DEFAULT now() NOT NULL,
	"updatedAt" timestamp DEFAULT now() NOT NULL,
	"createdBy" integer,
	CONSTRAINT "properties_referenceCode_unique" UNIQUE("referenceCode"),
	CONSTRAINT "properties_slug_unique" UNIQUE("slug")
);
--> statement-breakpoint
CREATE TABLE "propertyImages" (
	"id" serial PRIMARY KEY NOT NULL,
	"propertyId" integer NOT NULL,
	"imageUrl" varchar(500) NOT NULL,
	"imageKey" varchar(500) NOT NULL,
	"isPrimary" integer DEFAULT 0 NOT NULL,
	"displayOrder" integer DEFAULT 0 NOT NULL,
	"caption" varchar(255),
	"createdAt" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "reviews" (
	"id" serial PRIMARY KEY NOT NULL,
	"clientName" varchar(255) NOT NULL,
	"clientRole" varchar(100),
	"clientPhoto" varchar(500),
	"rating" integer NOT NULL,
	"title" varchar(255),
	"content" text NOT NULL,
	"propertyId" integer,
	"leadId" integer,
	"approved" boolean DEFAULT false,
	"featured" boolean DEFAULT false,
	"displayOrder" integer DEFAULT 0,
	"createdAt" timestamp DEFAULT now() NOT NULL,
	"updatedAt" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "site_settings" (
	"id" serial PRIMARY KEY NOT NULL,
	"companyName" varchar(255),
	"companyDescription" text,
	"companyLogo" varchar(500),
	"realtorName" varchar(255),
	"realtorPhoto" varchar(500),
	"realtorBio" text,
	"realtorCreci" varchar(50),
	"phone" varchar(20),
	"whatsapp" varchar(20),
	"email" varchar(320),
	"address" text,
	"instagram" varchar(255),
	"facebook" varchar(255),
	"youtube" varchar(255),
	"tiktok" varchar(255),
	"linkedin" varchar(255),
	"siteTitle" varchar(255),
	"siteDescription" text,
	"siteKeywords" text,
	"googleAnalyticsId" varchar(50),
	"facebookPixelId" varchar(50),
	"updatedAt" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "transactions" (
	"id" serial PRIMARY KEY NOT NULL,
	"type" varchar(50) NOT NULL,
	"category" varchar(100),
	"amount" numeric(12, 2) NOT NULL,
	"currency" varchar(3) DEFAULT 'BRL',
	"propertyId" integer,
	"leadId" integer,
	"ownerId" integer,
	"description" text NOT NULL,
	"notes" text,
	"status" varchar(50) DEFAULT 'pending',
	"paymentMethod" varchar(50),
	"paymentDate" date,
	"dueDate" date,
	"receiptUrl" varchar(500),
	"invoiceNumber" varchar(100),
	"createdAt" timestamp DEFAULT now() NOT NULL,
	"updatedAt" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "users" (
	"id" serial PRIMARY KEY NOT NULL,
	"openId" varchar(64) NOT NULL,
	"name" text,
	"email" varchar(320),
	"loginMethod" varchar(64),
	"role" "role" DEFAULT 'user' NOT NULL,
	"createdAt" timestamp DEFAULT now() NOT NULL,
	"updatedAt" timestamp DEFAULT now() NOT NULL,
	"lastSignedIn" timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "users_openId_unique" UNIQUE("openId")
);
--> statement-breakpoint
CREATE TABLE "webhook_logs" (
	"id" serial PRIMARY KEY NOT NULL,
	"source" varchar(50) NOT NULL,
	"event" varchar(100) NOT NULL,
	"payload" text,
	"response" text,
	"status" "webhook_status" NOT NULL,
	"errorMessage" text,
	"createdAt" timestamp DEFAULT now() NOT NULL
);
