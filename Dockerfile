# QuantDinger Backend API
# Uses pre-built official multi-arch image from GHCR
FROM ghcr.io/openbyteinc/quantdinger-backend:latest

WORKDIR /app
EXPOSE 80 5000

# Listen on port 80 by default for Easypanel, Coolify and cloud proxies
ENV PYTHON_API_PORT=80

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["gunicorn", "-c", "gunicorn_config.py", "run:app"]
