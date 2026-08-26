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

OpenAPI schema and generated client/server packages for the IVOA ExecutionBroker
web service (formerly known as Calycopis-schema).

## High-level overview

* This project defines the OpenAPI 3.1.0 schema for the IVOA Execution Broker web service and generates client and server packages from it.
* The schema is defined as a set of YAML files under `schema/v1.0/`, with `execution-broker.yaml` as the top-level entry point.
* A pre-processor (isobeon, a git submodule) resolves `$ref` references and merges the multi-file schema into a single output file used by the code generators.
* Code is generated for three targets: a Java Spring Boot server library (`calycopis-openapi-spring`), a Java client library (`calycopis-openapi-client`), and a Python client library (`calycopis_openapi_client`).
* Versions are driven from `config.yaml` via `bin/versions.sh`.

## Project structure

### Directory layout

* `schema/v1.0/` - The source OpenAPI 3.1.0 schema files.
  * `execution-broker.yaml` - Top-level schema entry point defining the web-service API paths.
  * `components.yaml` - Shared component definitions (execution requests, sessions, options, updates, etc.).
  * `messages.yaml` - Message types used in responses (`MessageItem`, `MessageList`).
  * `utils.yaml` - Reusable utility types (`NameValueMap`, `ISO8601*`, `MinMax*`, `ComputeUnitsEnum`).
  * `kinds/` - Concrete resource kind schemas, organised by category (compute, costs, data, executable, metrics, storage, volume).
* `isobeon/` - The schema pre-processor (Python, git submodule). Resolves `$ref` references and produces a single merged YAML file.
* `bin/` - Shell scripts for building the schema and all generated packages.
  * `versions.sh` - Reads `config.yaml` and sets the schema/Java/Python version variables.
  * `buildschema.sh` - Runs the isobeon pre-processor to produce the combined schema.
  * `buildjavaspring.sh` - Builds the Java Spring server package.
  * `buildjavaclient.sh` - Builds the Java client package.
  * `buildpythonclient.sh` - Builds the Python client package.
* `codegen/java/spring/` - Maven project that generates the Java Spring Boot server classes from the schema.
* `codegen/java/client/` - Maven project that generates the Java client classes from the schema.
* `codegen/python/client/` - Maven project that generates the Python client package.
  * `wrappers/` - Hand-written wrapper layer (`execution_client.py`, `models.py`) providing a higher-level API on top of the generated client.
  * `target/` - Output directory for the generated Python client package (generated, not committed).
* `config.yaml` - Project configuration: schema path/version, Java build suffix, Python build suffix.
* `.github/workflows/` - GitHub Actions workflows for building and publishing the packages.
* `notes/` - Development session notes.
* `.cursor/rules/` - Editor rules for AI-assisted development (licence headers, AIMetrics, copyright year).

## API surface

The web-service API (OpenAPI 3.1.0) exposes the following paths. Each endpoint
accepts and returns JSON, XML, and YAML content:

* `POST /requests` - Submit an execution request; either redirects (303) to the created offer-set or returns the `OfferSetResponse` (200).
* `POST /direct` - Submit a direct execution request that skips the offer process; redirects (303) to the created session or returns an `AbstractExecutionSession` (200).
* `GET /offersets/{uuid}` - Retrieve an offer-set.
* `GET /sessions/{uuid}` - Retrieve an execution session.
* `POST /sessions/{uuid}` - Update an execution session (e.g. change phase via an `AbstractUpdate`).

## Prerequisites

* **Python 3.9+** with `pyyaml` (for the schema pre-processor) and `yq` (for `bin/versions.sh`)
* **Java 21** (for the Maven-based code generators; CI uses Java 25)
* **Maven** (provided via the `mvnw` wrapper in each codegen project)
* **pip**, **build**, and **twine** (for building the Python package)

## Build process

The build steps are individual scripts in `bin/`. All commands below assume the
working directory is the project root.

### Step 1: Install schema pre-processor dependencies

```
pip install -r isobeon/requirements.txt
```

### Step 2: Configure the versions

`bin/versions.sh` reads `config.yaml` and exports the schema version, the combined
schema filename, and the Java/Python package versions:

```
source bin/versions.sh config.yaml
```

With the current `config.yaml` this sets:

* `schemashort` - the schema path (`v1.0`)
* `schemaversion` - the schema version (`1.0.7`)
* `combinedschema` - the merged schema filename (`execution-broker-1.0.7.yaml`)
* `javaversion` - the Java package version (`1.0.7-SNAPSHOT`)
* `pythonversion` - the Python package version (`1.0.7.dev5`)

When run inside a GitHub Actions job it also writes these values to `GITHUB_ENV`.

### Step 3: Process the schema

`bin/buildschema.sh` runs the isobeon pre-processor to merge the multi-file
schema into a single YAML file under `/tmp`:

```
bin/buildschema.sh
```

This is equivalent to:

```
python isobeon/schema-processor.py \
    schema/v1.0/execution-broker.yaml \
    /tmp/execution-broker-1.0.7.yaml
```

### Step 4: Build and install the Java Spring server package

`bin/buildjavaspring.sh` builds and installs the `calycopis-openapi-spring` Maven
artifact into the local Maven repository. The Calycopis-broker project depends on
this artifact.

The Maven POM uses the `openapi-generator-maven-plugin` to generate classes from
the processed schema at build time, so Step 3 must be completed first.

```
bin/buildjavaspring.sh
```

This is equivalent to:

```
pushd codegen/java/spring/
./mvnw \
    -Drevision=1.0.7-SNAPSHOT \
    -Dcalycopis.schema.file=/tmp/execution-broker-1.0.7.yaml \
    clean install
popd
```

Generated sources are written to:
`codegen/java/spring/target/generated-sources/openapi/`

### Step 5: Build and install the Java client package

`bin/buildjavaclient.sh` builds and installs the `calycopis-openapi-client` Maven
artifact into the local Maven repository.

```
bin/buildjavaclient.sh
```

This is equivalent to:

```
pushd codegen/java/client/
./mvnw \
    -Drevision=1.0.7-SNAPSHOT \
    -Dcalycopis.schema.file=/tmp/execution-broker-1.0.7.yaml \
    clean install
popd
```

### Step 6: Build the Python client package

`bin/buildpythonclient.sh` uses the Maven `openapi-generator-maven-plugin` to
generate the Python client into `codegen/python/client/target/`, copies the
hand-written wrapper layer into the generated package, and builds it:

```
bin/buildpythonclient.sh
```

This is equivalent to:

```
pushd codegen/python/client/
./mvnw \
    -Drevision=1.0.7.dev5 \
    -Dcalycopis.schema.file=/tmp/execution-broker-1.0.7.yaml \
    clean generate-sources
popd

cp -r codegen/python/client/wrappers \
    codegen/python/client/target/calycopis_openapi_client/wrappers

python -m build codegen/python/client/target
```

The wheel is written to `codegen/python/client/target/dist/`.

### Step 7: Install the Python client locally

To make the generated Python client available in the development environment:

```
pip install codegen/python/client/target/dist/*.whl
```

## Full build sequence

To build everything from scratch:

```
pip install -r isobeon/requirements.txt
source bin/versions.sh config.yaml

bin/buildschema.sh
bin/buildjavaspring.sh
bin/buildjavaclient.sh
bin/buildpythonclient.sh
pip install codegen/python/client/target/dist/*.whl
```

## Schema version

The current schema version is `1.0.7` (defined in `config.yaml`). Derived versions:

* Java packages: `1.0.7-SNAPSHOT`
* Python package: `1.0.7.dev5`

The version is applied to:

* The processed schema output filename (`execution-broker-1.0.7.yaml`)
* The Maven builds via `-Drevision=...` (all three POMs)
* The generated Python package (`packageVersion` in the POM `configOptions`)

## Code generation details

All three targets use the `openapi-generator-maven-plugin` (v7.23.0) embedded in
their Maven POM, and all generated model classes are prefixed with `Ivoa`
(e.g. `IvoaSimpleComputeResource`).

### Java Spring server (`calycopis-openapi-spring`)

* Generator: `openapi-generator-maven-plugin` v7.23.0
* Parent POM: `spring-boot-starter-parent` 4.1.0
* API package: `net.ivoa.calycopis.openapi.spring.api`
* Model package: `net.ivoa.calycopis.openapi.spring.model`
* Uses the `delegatePattern` for Spring controller delegation
* Generates XML support (`withXml`)
* Date mappings: `DateTime` → `java.time.Instant`, `Date` → `java.util.Date`

### Java client (`calycopis-openapi-client`)

* Generator: `openapi-generator-maven-plugin` v7.23.0
* API package: `net.ivoa.calycopis.openapi.client.api`
* Model package: `net.ivoa.calycopis.openapi.client.model`
* Uses the `native` library
* Date mappings: `DateTime` → `java.time.Instant`, `Date` → `java.util.Date`

### Python client (`calycopis_openapi_client`)

* Generator: `openapi-generator-maven-plugin` v7.23.0 (generator `python`)
* Package name: `calycopis_openapi_client`
* Output directory: `codegen/python/client/target/`
* Includes a hand-written wrapper layer at `calycopis_openapi_client/wrappers/`
  providing a higher-level `ExecutionBrokerClient` class for submitting offer-set
  requests, polling session phases, and updating sessions.

## CI/CD

The GitHub Actions workflows in `.github/workflows/`:

* `build-packages.yml` - The main build and publish workflow. Jobs:
  * `build-combined-schema` - Runs the isobeon pre-processor and uploads the merged schema as an artifact.
  * `build-python-client` - Generates and builds the Python wheel; publishes it to the UKSRC Nexus `localpypi` repository on pushes to `main` (when run from the `uksrc/Calycopis-openapi` repository).
  * `build-java-client` - Builds the Java client jar; deploys it to the UKSRC Nexus Maven repository or the IVOA GitHub Packages repository on pushes to `main`.
  * `build-java-spring` - Builds the Java Spring jar; deploys it to the UKSRC Nexus Maven repository or the IVOA GitHub Packages repository on pushes to `main`.
* `test-workflow.yml` - A small workflow used to test environment variable and secret propagation through GitHub Actions steps.
