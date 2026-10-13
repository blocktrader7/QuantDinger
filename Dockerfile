# QuantDinger Backend API
# Uses pre-built official multi-arch image from GHCR
FROM ghcr.io/openbyteinc/quantdinger-backend:latest

WORKDIR /app
EXPOSE 5000

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["gunicorn", "-c", "gunicorn_config.py", "run:app"]
