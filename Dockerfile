# Stage 1: Build Stage
FROM node:18-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install --production

# Stage 2: Pull Stage (for caching and optimization)
FROM node:18-alpine AS puller

WORKDIR /app

# Copy built node_modules from builder
COPY --from=builder /app/node_modules ./node_modules

# Copy application code
COPY app.js .
COPY public/ ./public/

# Stage 3: Security Scan Stage (Trivy will scan in CI/CD)
FROM puller AS scanner

# This stage is used for security scanning in the pipeline
RUN echo "Security scanning will be performed in CI/CD pipeline"

# Stage 4: Final Production Stage
FROM node:18-alpine

WORKDIR /app

# Create non-root user for security
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nodejs -u 1001

# Copy from puller stage
COPY --from=puller --chown=nodejs:nodejs /app/node_modules ./node_modules
COPY --from=puller --chown=nodejs:nodejs /app/app.js .
COPY --from=puller --chown=nodejs:nodejs /app/public ./public

# Switch to non-root user
USER nodejs

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3000/health', (r) => {if (r.statusCode !== 200) throw new Error(r.statusCode)})"

# Start application
CMD ["node", "app.js"]
