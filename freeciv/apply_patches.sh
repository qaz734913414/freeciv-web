#!/bin/sh

# activity_null_check is for Freeciv bug #22700.
# proto_requirement is Freeciv patch #5970
# proto_requirement_clean is Freeciv patch #6008
# proto_clean_bitstring is Freeciv patch #6009
# proto_clean_array_x_data_type is Freeciv patch #6010
# proto_jarray_api is Freeciv patch #6017
# proto_jarray_field is Freeciv patch #6028

PATCHLIST="proto_requirement proto_requirement_clean proto_clean_bitstring proto_clean_array_x_data_type proto_jarray_api proto_jarray_field freeciv_web_all_packets_def_changes caravan_fixes1 city_fixes city_impr_fix2 city_name_bugfix city-naming-change city_fixes2 citytools_changes map-settings metachange text_fixes unithand-change2 webclient-ai-attitude current_research_cost freeciv-svn-webclient-changes network-rewrite-1 fcnet_packets misc_devversion_sync scenario_ruleset savegame savegame2 maphand_ch serverside_extra_assign libtoolize_no_symlinks spacerace city_disbandable ai_traits_crash unittools ruleset-capability worklists server_password aifill barbarian-names activity_null_check add_rulesets NoDeltaHeader"

apply_patch() {
  echo "*** Applying $1.patch ***"
  if ! patch -u -p1 -d freeciv < patches/$1.patch ; then
    echo "APPLYING PATCH $1.patch FAILED!"
    return 1
  fi
  echo "=== $1.patch applied ==="
}

# APPLY_UNTIL feature is used when rebasing the patches, and the working directory
# is needed to get to correct patch level easily.
if test "x$1" != "x" ; then
  APPLY_UNTIL="$1"
  au_found=false

  for patch in $PATCHLIST
  do
    if test "x$patch" = "x$APPLY_UNTIL" ; then
      au_found=true
    fi
  done
  if test "x$au_found" != "xtrue" ; then
    echo "There's no such patch as \"$APPLY_UNTIL\"" >&2
    exit 1
  fi
else
  APPLY_UNTIL=""
fi

. ./version.txt

if ! grep "NETWORK_CAPSTRING_MANDATORY=\"$ORIGCAPSTR\"" freeciv/fc_version 2>/dev/null >/dev/null ; then
  echo "Capstring to be replaced does not match one given in version.txt" >&2
  exit 1
fi

sed "s/$ORIGCAPSTR/$WEBCAPSTR/" freeciv/fc_version > freeciv/fc_version.tmp
mv freeciv/fc_version.tmp freeciv/fc_version
chmod a+x freeciv/fc_version

for patch in $PATCHLIST
do
  if test "x$patch" = "x$APPLY_UNTIL" ; then
    echo "$patch not applied as requested to stop"
    break
  fi
  if ! apply_patch $patch ; then
    echo "Patching failed ($patch.patch)" >&2
    exit 1
  fi
done

# have Freeciv's "make install" add the Freeciv-web rulesets
cp -Rf data/fcweb data/webperimental freeciv/data/
