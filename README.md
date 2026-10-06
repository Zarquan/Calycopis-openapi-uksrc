<!--
  <meta:header>
    <meta:licence>
      Copyright (c) 2026, Manchester University (http://www.manchester.ac.uk/)

      This work is made available under the Creative Commons
      Attribution-ShareAlike 4.0 International licence.

      For details of the licence terms see:
      https://creativecommons.org/licenses/by-sa/4.0/
    </meta:licence>
  </meta:header>

  AIMetrics: [
      {
      "timestamp": "2026-08-26T12:21:45",
      "name": "Cursor CLI",
      "version": "2026.02.13-41ac335",
      "model": "Claude 4.6 Opus (Thinking)",
      "contribution": {
        "value": 100,
        "units": "%"
        }
      }
    ]
-->

# Calycopis-openapi

OpenAPI schema and generated client/server packages for the IVOA ExecutionBroker web service (formerly known as Calycopis-schema).

This project is named after the trebula groundstreak (Calycopis_trebula) butterfly.
<a title="Charles J. Sharp, CC BY-SA 4.0 &lt;https://creativecommons.org/licenses/by-sa/4.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:Trebula_groundstreak_(Calycopis_trebula).jpg"><img width="512" alt="Trebula groundstreak (Calycopis trebula)" src="https://upload.wikimedia.org/wikipedia/commons/thumb/8/8d/Trebula_groundstreak_%28Calycopis_trebula%29.jpg/512px-Trebula_groundstreak_%28Calycopis_trebula%29.jpg?20190617114007"></a>

Current work on this project is being developed as part of the SKA SRCNet and UKSRC programs.

## What this project provides

* The IVOA ExecutionBroker **OpenAPI 3.1.0 schema** under `schema/v1.0/`, with `execution-broker.yaml` as the top-level entry point.
* An **isobeon** schema pre-processor (git submodule) that resolves `$ref` references and merges the multi-file schema into a single YAML file for the code generators.
* Generated packages, all built with the `openapi-generator-maven-plugin`:
  * **Java Spring Boot server** — `calycopis-openapi-spring`
  * **Java client** — `calycopis-openapi-client`
  * **Python client** — `calycopis_openapi_client` (including a hand-written `wrappers/` layer with the higher-level `ExecutionBrokerClient`)

## Getting started

See [AGENTS.md](AGENTS.md) for the full project structure, build process, code generation details, and CI/CD workflows.

[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.0-4baaaa.svg)](CODE_OF_CONDUCT.md)
