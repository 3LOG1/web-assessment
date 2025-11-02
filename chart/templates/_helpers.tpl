{{- define "http-app.name" -}}
{{- .Chart.Name -}}
{{- end -}}

{{- define "http-app.fullname" -}}
{{- printf "%s-%s" .Release.Name (include "http-app.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "http-app.configmap" -}}
{{- printf "%s-config" (include "http-app.fullname" .) -}}
{{- end -}}


{{- define "http-app.configmap-checksum" -}}
{{- include "http-app.configmap" . | sha256sum -}}
{{- end -}}
