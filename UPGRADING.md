# Upgrading

## 1.x to 2.0

Two changes, one major. Both are in-place: no private endpoint or private link service is
replaced by the upgrade.

### azurerm 5 is required

azurerm v5 renamed `azurerm_private_link_service.enable_proxy_protocol` to
`proxy_protocol_enabled`. A module can only spell the argument one way, so v2 requires
`azurerm >= 5`. v1.x, which declares `>= 4`, already failed `terraform validate` on a fresh
`init` because the floor let v5 resolve.

1. Move the root to `azurerm ~> 5.0` and read the
   [azurerm 5.0 upgrade guide](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/5.0-upgrade-guide)
   for the renames it applies outside this module.
2. Pin this module to `~> 2.0` and run `terraform init -upgrade`.

Consumers who cannot move to azurerm 5 stay on `~> 1.0`, which keeps working on 4.x.

### `subresource_name` is replaced by `subresource_names`

The provider's field is a list, and a target can expose more than one sub-resource on a
single endpoint. v2 exposes the list and drops the singular form.

```hcl
# 1.x
subresource_name = "blob"

# 2.0
subresource_names = ["blob"]
```

The first entry is used when the module derives the default endpoint and NIC names, so a
one-element list produces the same names as before and the plan shows no change to existing
endpoints. `ip_configuration[*].subresource_name` is unchanged: it is the provider's own
per-IP field and stays singular.
